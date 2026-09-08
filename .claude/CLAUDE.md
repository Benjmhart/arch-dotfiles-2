# Global instructions

## Git

- Pushing to GitHub works from a tool session as of 2026-08-23. `~/.ssh/id_ed25519_agent` is a
  passphrase-less key pinned for `github.com` in `~/.ssh/config`, so nothing prompts. The old rule
  here — never push, because the passphrase would hang — described a real constraint that has
  since been removed; do not reason from it.
- Still do not push unprompted. Commit locally, surface what is unpushed, and push when asked.
  Pushing is outward-facing and awkward to walk back, which is a different reason from the
  mechanical one above and is still in force.
- Never force-push. Never push `~/secrets` without asking first — it holds the KeePassXC vault,
  and a bad push there costs more than a bad push of code.
- Non-GitHub remotes still use the passphrase-protected `id_rsa` and can still block on a prompt.
  Leave those to the user.

## Talking to agents in other repos

Many sessions run at once, roughly one per repo, across beast-arch and carbon. Two rules, both
paid for by real incidents (beast-arch task 59).

**Cite a commit SHA in any claim about another repo's state.** "as of `b8e6023` on
`mlabs-marketing/main`" lets the reader run `git cat-file -e b8e6023` and learn *"I do not have
that commit yet"* instead of *"that never happened"*.

**Never assert a negative about another repo's history without fetching first.** `git fetch`, then
claim. On 2026-09-05 a handover note was declared *"absent from the whole of that repo's history"*
while it sat committed and unpushed, and a generator run from the same stale clone would have
deleted 14 live records. **Absence in git is indistinguishable from absence in fact**, so the
mistake does not look like an error — it looks like a well-evidenced finding.

**Push before minting anything another workspace allocates from.** Fetching protects the
*reader* and cannot protect the *writer*: `git fetch` fixes a stale clone, but nothing reaches a
commit that never left this machine. So when you allocate from a shared sequence — an outbound
ID, a NAG number, a record id — the unpushed commit holding your allocation is invisible to every
other workspace, and the next one mints the same value. That is not hypothetical: **NAG-036's
outbound ID collided on 2026-09-06**, two workspaces minting from one sequence while one held
unpushed commits. Ask to push at the point of minting, not at the end of the session.

**Do not write files into another repo's working tree.** It dirties the tree, and the BMAD
governor refuses to dispatch work to a project with a dirty tree — so a note left for an agent
blocks that agent from ever being given work. Use the spool instead:

    ~/projects/station-maintenance/bin/inbox send --to <repo> --subject ... --sha <commit>
    bin/inbox list        # pending for the repo you are in; a SessionStart hook also shows these
    bin/inbox ack <id>    # or: bin/inbox drop <id> --reason ...

A message closes by `ack` or by `drop` with a reason. **It does not close by being ignored.**

The spool is a mailbox, not a doorbell — but it is read often: `SessionStart` fires on `clear`,
`compact`, `resume` and `fork` as well as `startup`, so a long-lived session sees its inbox at
every `/clear` and every compaction. What it does not reach is a session mid-turn; for that, use
`SendMessage` or `herdr agent prompt`.
