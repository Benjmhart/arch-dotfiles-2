# ~/.zshenv -- read by EVERY zsh, including non-interactive ones.
#
# Written 2026-09-08 for station-maintenance beast-arch task 61.
#
# WHY THIS FILE EXISTS
# ~/.zshrc is read only by INTERACTIVE shells. Everything it exports is therefore
# invisible to `ssh host 'cmd'`, to a script with a zsh shebang, and to anything
# else that does not open an interactive session. Two of those exports are load
# bearing, and one of them fails silently when missing:
#
#   * XDG_CONFIG_HOME=$HOME/.configure -- this machine's config lives in
#     ~/.configure, NOT ~/.config. Without it, herdr resolves
#     ~/.config/herdr/herdr.sock, a path that does not exist here, and returns
#     A SECOND EMPTY SESSION WHILE EXITING 0. It does not error. A wrong answer
#     that succeeds is worse than a failure, and gh does the same thing with
#     ~/.configure/gh/hosts.yml, answering "please run gh auth login".
#
#   * ~/.local/bin on PATH -- non-interactive PATH is
#     /bin:/usr/bin:/usr/ucb:/usr/local/bin, so `herdr` is "command not found".
#     Loud, and therefore the harmless half.
#
# Found when a carbon session ran `ssh beast-arch 'herdr agent list'` over the
# tailnet on 2026-09-07 and had to pass both by hand.
#
# ★ typeset -U MUST COME FIRST, AND IT IS NOT DECORATION. ★
# Before 2026-08-02 each nested shell doubled the path list -- the long-running
# herdr server had accumulated the same entries a dozen times. ~/.zshrc:13 fixed
# it for interactive shells. This file runs for nested and non-interactive ones
# too, so without the same line here the identical bug comes straight back, in
# the shells nobody watches.
typeset -U path PATH

export XDG_CONFIG_HOME="$HOME/.configure"
export XDG_CACHE_HOME="$HOME/.cache"

# Deliberately only the two directories a non-interactive caller actually needs.
# ~/.zshrc builds the full list; duplicates collapse via typeset -U above, so
# naming these twice costs nothing. Keep this short -- every zsh pays for it.
path=(
  $HOME/bin
  $HOME/.local/bin
  $path
)
export PATH

# NOTHING HERE MAY PRINT. .zshenv runs for scp and sftp too, and stray output on
# stdout corrupts those transfers. No echo, no banners, no command substitution
# that might warn.
#
# ⚠️ THIS DOES NOT FIX SYSTEMD USER UNITS. They do not invoke zsh at all, so they
# still need Environment=XDG_CONFIG_HOME=%h/.configure in the unit file. Do not
# read this file as having retired that requirement.
