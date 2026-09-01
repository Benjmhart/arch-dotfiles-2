#!/usr/bin/env python3
"""Claude Code status line -- beast-arch.

Reads the session JSON on stdin, prints ONE line on stdout.

Written 2026-08-03 for station-maintenance task 7.

Why python3 and not jq: THERE IS NO jq ON THIS MACHINE (verified 2026-08-03 --
`pacman -Qq jq` errors, and there is no gojq/jaq/nix-profile copy either). Every
statusline recipe in the wild pipes through jq; all of them would fail silently
here, because Claude Code renders a failing statusline command as an empty line
rather than an error. python3 is in the base install and needs no dependency.

Every field read below is optional in the contract, so each one is guarded. A
KeyError here costs a blank status bar, not a crash -- Claude Code renders a
failing statusline command as an empty line and says nothing.

Shows, left to right: vim mode, model, context remaining, reasoning effort,
subscription limits. Working directory and git branch were dropped 2026-08-05.

DOUBLE DUTY, added 2026-09-01 for station-maintenance task 58 (BMAD job queue):
this script is also the machine's ONLY quota sensor. The `rate_limits` object below
is pushed here by Claude Code on every render and is written to disk NOWHERE ELSE --
there is no `claude usage` subcommand, stats-cache.json went stale 2026-08-10, and no
ccusage-style tool is installed. So each render appends one line to
~/.local/state/bmad-queue/quota.jsonl, which is what the job queue's pacing logic reads.

The sensor is deliberately subordinate to the status line: the line is written to
stdout FIRST, and every byte of sensor I/O is wrapped in a bare except. A broken
sensor must never cost a blank status bar -- Claude Code renders a failing statusline
command as an empty line and says nothing, so the failure would be silent and daily.
"""

import json
import os
import sys
import time

# Sensor state. Not in the repo: this is a machine-local ledger, not configuration.
STATE_DIR = os.path.expanduser("~/.local/state/bmad-queue")
QUOTA_LOG = os.path.join(STATE_DIR, "quota.jsonl")
# One-shot raw capture, so the full payload schema can be read once and then reasoned
# about offline. Written only if absent; delete the file to re-capture.
RAW_DUMP = os.path.join(STATE_DIR, "statusline-payload-sample.json")
# quota.jsonl is append-only and unrotated. At ~120 bytes a render this would grow
# without bound, so stop appending past a ceiling rather than silently eating the disk.
MAX_LOG_BYTES = 32 * 1024 * 1024


def record(raw, d):
    """Append one quota observation. Never raises -- see module docstring."""
    try:
        os.makedirs(STATE_DIR, exist_ok=True)

        # One-shot schema capture. The question this answers: does `rate_limits`
        # carry a reset timestamp? If it does, the queue needs no window inference.
        if not os.path.exists(RAW_DUMP):
            try:
                with open(RAW_DUMP, "x") as fh:
                    fh.write(raw)
            except FileExistsError:
                pass  # raced with another session; harmless

        limits = d.get("rate_limits") or {}
        five = (limits.get("five_hour") or {}).get("used_percentage")
        seven = (limits.get("seven_day") or {}).get("used_percentage")
        # Nothing to record until the session has seen an API response. Writing a
        # null-null row would pollute the ledger with rows the pacing logic must
        # then learn to skip.
        if five is None and seven is None:
            return

        try:
            if os.path.getsize(QUOTA_LOG) > MAX_LOG_BYTES:
                return
        except OSError:
            pass  # absent yet, or unstattable; either way, try the append

        row = {
            "ts": time.time(),
            "five_hour_pct": five,
            "seven_day_pct": seven,
            "model": (d.get("model") or {}).get("id")
            or (d.get("model") or {}).get("display_name"),
            "session_id": d.get("session_id"),
            # Carried verbatim so the pacing logic can use a real reset boundary if
            # one is present, instead of inferring the window from a drop in used%.
            "rate_limits": limits,
        }
        # O_APPEND + a single write() keeps concurrent sessions from interleaving.
        # There are routinely ~10 live sessions on this box, all rendering.
        with open(QUOTA_LOG, "a") as fh:
            fh.write(json.dumps(row, separators=(",", ":")) + "\n")
    except Exception:
        return

# --- ANSI ------------------------------------------------------------------
DIM = "\033[2m"
RESET = "\033[0m"
BOLD = "\033[1m"
CYAN = "\033[36m"
GREEN = "\033[32m"
YELLOW = "\033[33m"
RED = "\033[31m"
MAGENTA = "\033[35m"
SEP = f"{DIM} · {RESET}"

# Vim mode -> colour. Deliberately distinct hues rather than shades: this is read
# with peripheral vision, and "which mode am I in" is the whole point of showing it.
# Claude Code only sends the `vim` object at all when editorMode is "vim", and it
# defaults the value to INSERT, so an unknown mode is far more likely to be a new
# mode name than a bug -- fall back to plain rather than dropping it.
VIM_COLOURS = {
    "NORMAL": GREEN,
    "INSERT": YELLOW,
    "VISUAL": MAGENTA,
}


def main():
    # Read as text, not json.load(stdin): the raw string is needed for the one-shot
    # schema capture in record(), and re-serialising a parsed dict would lose any
    # field this script does not model.
    try:
        raw = sys.stdin.read()
        d = json.loads(raw)
    except (json.JSONDecodeError, ValueError, OSError):
        return

    parts = []

    # Vim mode FIRST. Added 2026-08-05 with editorMode="vim". It leads because it is
    # the field that changes most often and the one a mistake is most expensive on --
    # typing a sentence into NORMAL mode fires a scatter of one-key commands. The
    # `vim` key is absent entirely unless editorMode is "vim", so this costs nothing
    # and renders nothing when vim mode is off.
    vim = (d.get("vim") or {}).get("mode")
    if vim:
        parts.append(f"{VIM_COLOURS.get(vim, '')}{BOLD}{vim}{RESET}")

    # Model.
    model = (d.get("model") or {}).get("display_name")
    if model:
        parts.append(f"{CYAN}{model}{RESET}")

    # Removed 2026-08-05 at Ben's request: working directory and git branch. Both are
    # already visible elsewhere -- the shell prompt carries the path, and the branch is
    # a `git status` away. Dropping the branch also removes the only subprocess this
    # script ran, so the status line no longer forks two `git` processes on a line that
    # re-renders on every keystroke.

    # Context remaining. Explicit `is not None` -- 0 is a real, and alarming, value.
    ctx = d.get("context_window") or {}
    rem = ctx.get("remaining_percentage")
    if rem is not None:
        colour = RED if rem < 15 else YELLOW if rem < 30 else DIM
        parts.append(f"{colour}ctx {rem:.0f}%{RESET}")

    # Reasoning effort -- only present when the model supports it.
    effort = (d.get("effort") or {}).get("level")
    if effort:
        parts.append(f"{DIM}{effort}{RESET}")

    # Subscription limits, when the session has seen an API response.
    limits = d.get("rate_limits") or {}
    bits = []
    for key, tag in (("five_hour", "5h"), ("seven_day", "7d")):
        used = (limits.get(key) or {}).get("used_percentage")
        if used is not None:
            bits.append(f"{tag} {used:.0f}%")
    if bits:
        worst = max(
            (limits.get(k) or {}).get("used_percentage") or 0
            for k in ("five_hour", "seven_day")
        )
        colour = RED if worst >= 90 else YELLOW if worst >= 75 else DIM
        parts.append(f"{colour}{' '.join(bits)}{RESET}")

    sys.stdout.write(SEP.join(parts))
    # Flush before the sensor runs: the status line is the job, the ledger is the
    # side effect, and the side effect must not be able to swallow the job.
    try:
        sys.stdout.flush()
    except Exception:
        pass

    record(raw, d)


if __name__ == "__main__":
    main()
