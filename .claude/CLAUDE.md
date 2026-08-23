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
