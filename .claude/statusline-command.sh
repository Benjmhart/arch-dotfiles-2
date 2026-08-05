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
"""

import json
import sys

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
    try:
        d = json.load(sys.stdin)
    except (json.JSONDecodeError, ValueError):
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


if __name__ == "__main__":
    main()
