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
#   * XDG_CONFIG_HOME -- until 2026-10-04 every machine kept its config in
#     ~/.configure, and a shell without this export resolved herdr's socket and
#     gh's hosts.yml under ~/.config and got A WRONG ANSWER WHILE EXITING 0 (a
#     second empty herdr session; "please run gh auth login"). Since 2026-10-04
#     (station-maintenance media-center task 3, arch-bootstrap tools/xdg-migrate)
#     the config lives in ~/.config, the XDG default, and ~/.configure is a
#     symlink to it for anything that still names the old path. The export is
#     kept, explicit, so the shell and the systemd user manager agree by
#     construction rather than by default.
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

export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"

# One place for run logs and throwaway scripts (Ben, 2026-10-08: they were cluttering ~).
# Under XDG state, beside fleet/ and chores/. Nothing prunes it; delete by hand.
export OPS="$HOME/.local/state/ops"
[[ -d $OPS ]] || mkdir -p "$OPS"

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
# Systemd user units do not invoke zsh. Before 2026-10-04 they needed
# Environment=XDG_CONFIG_HOME=%h/.configure; now their default (~/.config) is the
# same directory, so no unit needs that line any more.
