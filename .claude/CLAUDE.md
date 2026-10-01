# Global instructions

## Git

- Pushing to GitHub works from a tool session, verified on beast-arch 2026-09-30 after the
  post-incident rebuild: `~/.ssh/id_ed25519` authenticates to `github.com` with no prompt.
  `~/.ssh/id_ed25519_agent` is listed first for `github.com` in `~/.ssh/config`. **On beast-arch it
  was removed from GitHub** during the incident response and is rejected, so ssh falls through to
  `id_ed25519`. **On carbon it is still registered** (`SHA256:27yM…`, kept by Ben's decision). Do not
  register another passphrase-less push key without asking: the incident (a phishing script that ran
  on a git branch change, 2026-09-28) had exactly that key's reach, which is push access to every repo. Record: `mlabs-marketing/state/incidents/2026-09-30-workstation-compromise.md`.
- Still do not push unprompted. Commit locally, surface what is unpushed, and push when asked.
  Pushing is outward-facing and awkward to walk back, which is a different reason from the
  mechanical one above and is still in force.
- Never force-push. Never push `~/secrets` without asking first — it holds the KeePassXC vault,
  and a bad push there costs more than a bad push of code.
- Non-GitHub remotes: the passphrase-protected `id_rsa` did not survive the 2026-09-29/30
  rebuilds (it is absent from beast-arch's `~/.ssh`). Anything that needs it will fail or prompt.
  Leave those to the user.

## Talking to agents in other repos

Many sessions run at once, roughly one per repo, across beast-arch and carbon. Five rules, all
paid for by real incidents (beast-arch task 59).

**Cite a commit SHA in any claim about another repo's state — and push it before you cite it.**
"as of `b8e6023` on `mlabs-marketing/main`" lets the reader run `git cat-file -e b8e6023` and learn
*"I do not have that commit yet"* instead of *"that never happened"*. **That only works while the
SHA is stable, and an unpushed SHA is not.** On **2026-09-11** a message cited `f1b3d96`; the sender
rebased before pushing — which `system pull` itself recommends as the ordinary fix for divergence —
and the work went out as `66a7a44` instead. `git cat-file -e f1b3d96` **still succeeds on the
sender's box** (unreachable from any branch, kept alive by the reflog until it is GC'd) and **fails
permanently everywhere else**. So the sender who checks their own citation before sending gets a
green light and ships a dead reference, and **no local test can catch it**; on the reader's side the
failure is indistinguishable from *"not pushed yet"*, collapsing the exact distinction this rule
exists to create. A SHA is an allocation in a shared namespace, exactly like the outbound IDs and NAG
numbers in *"Push before minting"* below: **push, then cite.** If you genuinely must cite first, say it is unpushed and name the branch and
machine — then **re-cite after the push**, which is the half that gets forgotten.

**Never assert a negative about another repo's history without fetching first.** `git fetch`, then
claim. On 2026-09-05 a handover note was declared *"absent from the whole of that repo's history"*
while it sat committed and unpushed, and a generator run from the same stale clone would have
deleted 14 live records. **Absence in git is indistinguishable from absence in fact**, so the
mistake does not look like an error — it looks like a well-evidenced finding.

**Absence in one place never licenses "it does not exist" — name the ref you checked.** `git
cat-file -e` scopes to a single commit; an unqualified `grep -rl` silently means *"at my HEAD,
whatever that is"*. Both return a confident zero that reads as well-evidenced. On **2026-09-09** I
grepped my own working tree, reported a line *"gone from the repo"*, and had to withdraw it — the
line was in `origin/main` the whole time and my HEAD held 11 unpushed commits. **Verify absence by
reading the region, not by matching a string in it**: `grep -c 'unpushed-commit gap'` returns **0**
against a line reading `the *unpushed-commit* gap`, because the emphasis markers sit inside the
phrase. Nothing about that one is SHA-shaped, so no amount of fetching helps it. *"Absent at
`f10a698`"* is a fact; *"absent"* is a guess about a working tree.

**Push before minting anything another workspace allocates from.** Fetching protects the
*reader* and cannot protect the *writer*: `git fetch` fixes a stale clone, but nothing reaches a
commit that never left this machine. So when you allocate from a shared sequence — an outbound
ID, a NAG number, a record id — the unpushed commit holding your allocation is invisible to every
other workspace, and the next one mints the same value. That is not hypothetical: **NAG-036's
outbound ID collided on 2026-09-06**, two workspaces minting from one sequence while one held
unpushed commits. Ask to push at the point of minting, not at the end of the session. **The same
timing applies to any SHA you cite** — see the first rule, where an unpushed one was rebased out
from under a message and the sender's own check could not detect it.

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
