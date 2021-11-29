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


export PATH="$HOME/.cargo/bin:$PATH"
