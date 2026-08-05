# Global instructions

## Git

- Never run `git push` (or any command that pushes to a remote). The user's SSH key requires a
  passphrase, so an automated push will hang or fail waiting for interactive input. Always leave
  pushing to the user — prepare the branch/commit locally and tell them it's ready to push.
