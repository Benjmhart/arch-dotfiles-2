#!/usr/bin/env python3
"""Claude Code status line -- beast-arch.

Reads the session JSON on stdin, prints ONE line on stdout.

Written 2026-08-03 for station-maintenance task 7.

Why python3 and not jq: THERE IS NO jq ON THIS MACHINE (verified 2026-08-03 --
`pacman -Qq jq` errors, and there is no gojq/jaq/nix-profile copy either). Every
statusline recipe in the wild pipes through jq; all of them would fail silently
here, because Claude Code renders a failing statusline command as an empty line
rather than an error. python3 is in the base install and needs no dependency.

Every field below is optional in the contract except session_id/model/workspace,
so each one is guarded. A KeyError here costs a blank status bar, not a crash.
"""

import json
import os
import subprocess
import sys

# --- ANSI ------------------------------------------------------------------
DIM = "\033[2m"
RESET = "\033[0m"
CYAN = "\033[36m"
GREEN = "\033[32m"
YELLOW = "\033[33m"
RED = "\033[31m"
SEP = f"{DIM} · {RESET}"


def git_info(cwd):
    """(branch, dirty) for cwd, or (None, False) if not a repo / git is slow.

    --no-optional-locks keeps a status line that renders on every keystroke from
    fighting a real git command for the index lock.
    """
    def run(args):
        return subprocess.run(
            ["git", "--no-optional-locks", "-C", cwd] + args,
            capture_output=True, text=True, timeout=1,
        )

    try:
        p = run(["rev-parse", "--abbrev-ref", "HEAD"])
        if p.returncode != 0:
            return None, False
        branch = p.stdout.strip()
        # Detached HEAD prints "HEAD"; show the short sha instead.
        if branch == "HEAD":
            s = run(["rev-parse", "--short", "HEAD"])
            branch = s.stdout.strip() or "detached"
        dirty = run(["diff", "--quiet", "HEAD"]).returncode != 0
        return branch, dirty
    except (subprocess.TimeoutExpired, OSError):
        return None, False


def main():
    try:
        d = json.load(sys.stdin)
    except (json.JSONDecodeError, ValueError):
        return

    parts = []

    # Model.
    model = (d.get("model") or {}).get("display_name")
    if model:
        parts.append(f"{CYAN}{model}{RESET}")

    # Working directory, as a basename -- the full path is already in the prompt.
    ws = d.get("workspace") or {}
    cwd = ws.get("current_dir") or d.get("cwd") or ""
    if cwd:
        parts.append(os.path.basename(cwd.rstrip("/")) or cwd)

    # Git branch. Worktree name wins if we are in one, since that is the thing
    # that is easy to forget you are inside.
    wt = (d.get("worktree") or {}).get("name") or ws.get("git_worktree")
    branch, dirty = git_info(cwd) if cwd else (None, False)
    if branch:
        label = f"{wt}:{branch}" if wt else branch
        parts.append(f"{GREEN}{label}{'*' if dirty else ''}{RESET}")

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

    # Vim mode, only when vim mode is on.
    vim = (d.get("vim") or {}).get("mode")
    if vim:
        parts.append(f"{YELLOW}{vim}{RESET}")

    sys.stdout.write(SEP.join(parts))


if __name__ == "__main__":
    main()
