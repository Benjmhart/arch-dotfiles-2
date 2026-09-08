#!/usr/bin/env bash
#
# agent-inbox.sh -- SessionStart hook: show this repo's pending agent messages.
#
# Registered as a SECOND SessionStart entry in ~/.claude/settings.json, beside
# herdr's hook. It is deliberately NOT written into herdr-agent-state.sh: that
# file says "managed by herdr; reinstalling or updating the integration
# overwrites this file. add custom hooks beside this file instead of editing it."
#
# It also does NOT copy herdr's `[ "${HERDR_ENV:-}" = "1" ] || exit 0` guard.
# herdr's hook is only meaningful inside a herdr pane; an inbox check is meaningful
# in every session, and copying that guard would make it silently do nothing
# outside herdr -- the exact class of failure beast-arch task 58 hit twice.
#
# WHY A HOOK AND NOT A CLAUDE.md LINE  (beast-arch task 59)
# The harness runs this, not the model, so it cannot be skipped under context
# pressure. A convention in prose can be and has been: task 54 sat marked "not
# applied" in the index for twelve days while it was in fact applied. Confirmed
# from the receiving end 2026-09-08: asked whether it would have read the spool
# without this hook, the session said no. The hook is the load-bearing part.
#
# Stdout from a SessionStart hook is added to the session's opening context, so
# whatever this prints is what the agent starts the session knowing.
#
# SessionStart fires with source `startup`, `resume`, `clear`, `compact` and `fork`
# -- so this runs at every /clear and every compaction, not just when Claude Code
# is restarted. That is what makes a spool viable for sessions that stay up for
# days. The matcher is `*` so all five are covered. Observed firing on a real
# `/clear` 2026-09-08, message delivered end to end.
#
# ★ IT ALWAYS PRINTS EXACTLY ONE STATUS LINE, EVEN WHEN THERE IS NOTHING TO SAY. ★
# Amended 2026-09-08. The first version returned silently on five paths -- no
# bin/inbox, no cwd, not a git repo, no spool dir, zero pending -- on the stated
# grounds that "0 pending" in every session is noise. That is the wrong trade and
# this repo has the receipts:
#
#   * The same task's layer-4 contract already requires the xmobar field to read
#     `Inbox: 0` rather than a glyph, precisely so that zero is distinguishable
#     from broken; `bin/inbox count` honours it ("NEVER prints nothing"). The hook
#     is the channel an AGENT reads, so it needs the property more, not less.
#   * A silently broken hook cannot be noticed by the agent it fails: an unread
#     message is indistinguishable from no message, and the session has no other
#     reason to look in the spool.
#
# So: healthy-and-empty says `0 pending`, and every abnormal path says UNAVAILABLE
# with the reason. One line of noise buys the ability to see the channel is alive.
#
# It must NEVER fail the session. Every path exits 0.

set -u

say() { echo "=== AGENT INBOX: $* ==="; }

INBOX="$HOME/projects/station-maintenance/bin/inbox"
if [ ! -x "$INBOX" ]; then
    say "UNAVAILABLE -- no executable bin/inbox at $INBOX"
    echo "Messages may be spooled and unreadable. See beast-arch task 59."
    exit 0
fi

# The hook receives JSON on stdin; `cwd` is the session's directory. Fall back to
# $PWD when the payload is absent or unparseable, because a missing field must not
# mean "no messages" -- that is indistinguishable from an empty inbox.
payload="$(cat 2>/dev/null || true)"
cwd="$(printf '%s' "$payload" | python3 -c '
import json,sys
try:
    print(json.load(sys.stdin).get("cwd") or "")
except Exception:
    print("")
' 2>/dev/null || true)"
[ -n "$cwd" ] || cwd="$PWD"

if [ ! -d "$cwd" ]; then
    say "UNAVAILABLE -- cannot resolve this session's directory (tried '$cwd')"
    exit 0
fi

# Repo name = the git toplevel's basename, or the directory's own basename when
# there is no git repo. This MUST match `repo_of()` in bin/inbox.
#
# ★ The non-git fallback closes a real delivery hole, found 2026-09-08. ★
# The first version gave up here and said "no mailbox" whenever cwd was not a git
# repo. 11 of the 27 directories in ~/projects are not git repos, four of them had
# live sessions at the time, and a message spooled to one of them was reported as
# "no mailbox" while it sat unread in the spool -- undeliverable and empty looked
# identical, again. Addressing is by repo NAME, and a name needs no .git.
repo="$(git -C "$cwd" rev-parse --show-toplevel 2>/dev/null || true)"
if [ -n "$repo" ]; then
    repo="$(basename "$repo")"
else
    repo="$(basename "$cwd")"
fi
if [ -z "$repo" ]; then
    say "UNAVAILABLE -- cannot derive a repo name from '$cwd'"
    exit 0
fi

spool="$HOME/.local/state/agent-inbox/$repo"
if [ -d "$spool" ]; then
    count="$(find "$spool" -maxdepth 1 -name '*.json' 2>/dev/null | wc -l)"
else
    # No spool directory means nothing has ever been sent to this repo. `send`
    # creates it. That is a real zero, not a fault.
    count=0
fi

if [ "$count" -eq 0 ]; then
    say "0 pending for $repo"
    exit 0
fi

say "$count pending message(s) for $repo"
if ! "$INBOX" list "$repo" --full; then
    echo "!! bin/inbox list FAILED -- $count message(s) are spooled in $spool and could"
    echo "!! not be rendered. Read them directly; do not assume the inbox is empty."
    exit 0
fi
echo "Close each one: \`bin/inbox ack <id>\` if you did it, or"
echo "\`bin/inbox drop <id> --reason ...\` if you are declining it."
echo "Being ignored is not a close -- it will still be here next session."
say "END"
exit 0
