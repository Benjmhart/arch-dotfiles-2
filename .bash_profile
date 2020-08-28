#
# ~/.bash_profile
#

[[ -f ~/.bashrc ]] && . ~/.bashrc
export PATH=$PATH:~/go/bin
export EDITOR=nvim
export TERMINAL=konsole
export BROWSER=firefox
export GOPATH=~/go/src
alias vim=nvim
alias mongod="docker run -d -p 27017:27017 --name mongodb mongo"
alias mongosh="docker exec -it mongodb bash"

if [ -e /home/ben/.nix-profile/etc/profile.d/nix.sh ]; then . /home/ben/.nix-profile/etc/profile.d/nix.sh; fi # added by Nix installer
