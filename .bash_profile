#
# ~/.bash_profile
#

[[ -f ~/.bashrc ]] && . ~/.bashrc
export PATH=$PATH:~/go/bin
export EDITOR=nvim
# Changed 2026-08-04 (beast-arch task 32): was `konsole`, which is not installed
# on this machine. The terminal here is alacritty -- xmonad's `terminal` setting,
# .xinitrc and every startup hook all use it.
export TERMINAL=alacritty
# Removed 2026-08-04 (beast-arch task 32): `export BROWSER=firefox`.
# This was the SECOND setter -- .zshrc sources this file at line 16 and then
# re-exported BROWSER at line 66, so vivaldi only won by running later. Any
# $BROWSER at all makes `xdg-settings set` refuse (exit 4), which is what broke
# Vivaldi's "set as default" button. The MIME database is the source of truth now.
# NOTE: `TERMINAL=konsole` above is also stale -- konsole is not installed and the
# terminal here is alacritty. Left alone; see beast-arch task 32.
export GOPATH=~/go/src
alias vim=nvim
alias mongod="docker run -d -p 27017:27017 --name mongodb mongo"
alias mongosh="docker exec -it mongodb bash"


export PATH="$HOME/.cargo/bin:$PATH"
