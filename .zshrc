# this lives in ~/.zshrc

# Keep PATH deduplicated. zsh ties the `path` array to the `PATH` string; -U makes
# it a unique set, dropping later duplicates and keeping the FIRST occurrence, so
# search precedence is preserved. Set before the sources below so that whatever
# they add is deduplicated too.
#
# This is load-bearing, not tidiness. The previous single-line PATH interpolated
# $PATH into itself twice, and .zshrc is re-read by every interactive shell, so
# each nested shell doubled the list. The long-running herdr server had ended up
# with the same entries repeated a dozen times. Fixed 2026-08-02; see
# station-maintenance, beast-arch.
typeset -U path PATH

source /etc/profile
source ~/.bash_profile

# Prepended to whatever /etc/profile and ~/.bash_profile establish.
#
# Removed 2026-08-02 -- verified not to exist on this machine:
#   ~/.cabal/config (a file, not a directory)  ~/.zshscripts   /snap/bin
#   ~/.nvm/versions/node/v10.16.3              /usr/lib/nix    ~/moonlander
#   ~/Projects/juspay/euler-test/scripts       ~/Projects/{j,J}uspay/euler-tools/scripts
#
# Also removed -- these exist but hold no executables meant to be run by bare name:
#   /nix, /etc/nix, ~/.stack, and ~/.nvm (nvm is used through the shell function
#   sourced further down; only ~/.nvm/nvm-exec was ever reachable this way).
#
# ~/.cargo/bin is kept although it does not currently exist -- rustup recreates it.
path=(
  $HOME/bin
  $HOME/.local/bin
  $HOME/.cargo/bin
  $HOME/go/bin
  $HOME/.local/share/gem/ruby/3.4.0/bin
  /usr/local/bin
  $path
)
export PATH

export GEM_HOME="$HOME/.ruby"

export VIFM=$HOME/.configure/vifm

export WINHOME=/mnt/c/Users/Ben

autoload -Uz compinit
compinit

export XDG_CONFIG_HOME=$HOME/.configure
export XDG_CACHE_HOME=$HOME/.cache

# Point every shell at the one systemd-managed ssh-agent
# (`systemctl --user enable --now ssh-agent.socket`, enabled 2026-08-02).
# Combined with `AddKeysToAgent 8h` in ~/.ssh/config this means the key
# passphrase is typed once per working day instead of once per push, and every
# terminal shares the same unlocked agent.
#
# Guarded, so an agent inherited from elsewhere still wins -- notably a
# forwarded agent over `ssh -A`, which must not be shadowed by the local one.
if [[ -z ${SSH_AUTH_SOCK:-} && -S ${XDG_RUNTIME_DIR:-/run/user/$UID}/ssh-agent.socket ]]; then
  export SSH_AUTH_SOCK="${XDG_RUNTIME_DIR:-/run/user/$UID}/ssh-agent.socket"
fi

export EDITOR=/bin/nvim
export BROWSER=/usr/bin/vivaldi-stable

export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"
export LC_COLLATE="en_US.UTF-8"

export HISTCONTROL=ignoreboth

#GOPATH
export GOPATH=~/Projects/go

if [[ -d "$HOME/.nvm" ]]
then
  source "$HOME/.nvm/nvm.sh"
else
  source "$HOME/.configure/nvm/nvm.sh"
fi
# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="robbyrussell" # also see kolo, robbyrussell, miloshadzic, simple

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in ~/.oh-my-zsh/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(gitfast command-not-found zsh-autosuggestions compleat npm cabal sudo vscode zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/rsa_id"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# AutoResolve Aliases
expand-aliases() {
  unset 'functions[_expand-aliases]'
  functions[_expand-aliases]=$BUFFER
  (($+functions[_expand-aliases])) &&
    BUFFER="${functions[_expand-aliases]#$'\t'}" &&
    CURSOR=$#BUFFER
}

zle -N expand-aliases
bindkey '^ ' expand-aliases


# vim mode switch delay
export KEYTIMEOUT=1
# see https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/vi-mode for mapping details

# allow 256 colors in konsole
export COLORTERM=truecolor

# Example aliases
alias zshrc="nvim ~/.zshrc"
alias cd..="cd .."
alias setmon3="$HOME/.screenlayout/tripleThreat.sh"
alias setmon1="$HOME/.screenlayout/single.sh"
alias setmonwide="$HOME/.screenlayout/wide.sh"
alias start3="$HOME/bin/start3.sh"
# alias start2="$HOME/bin/double.sh"
alias start1="$HOME/bin/single.sh"
alias startwide="$HOME/bin/startwide.sh"
alias projects="cd ~/Projects"
alias reload="source ~/.zshrc"
alias dotfiles="cd ~/dotfiles"
alias mongostart="docker run -d -p 27017-27019:27017-27019 --name mongod mongo"
alias mongod="docker start mongod"
alias mongo="docker exec -it mongod bash"
alias gitchron="git branch --sort=committerdate"
alias nvimrc="nvim ~/.configure/nvim/init.vim"
alias xampp="sudo /opt/lampp/manager-linux-x64.run"
alias capset="xmodmap ~/.Xmodmap"
alias please='sudo $(fc -ln -1)'
alias singletray="stalonetray --config ~/.stalonetrayrc-single"
alias alacrittyconfig="nvim ~/.configure/alacritty/alacritty.toml"
alias tmux="tmux -u"
unalias la
alias la="eza -a"
alias ls="eza"
alias bc="eva"
alias cat="bat"
alias clip="xclip -sel clip"
alias vimrc="nvim ~/.configure/nvim/init.vim"
alias localec="LC_ALL='C'"
alias localen="LC_ALL='en_US.UTF-8'"
alias dot="/usr/bin/git --git-dir=$HOME/.dot/ --work-tree=$HOME"
alias dotadd="dot add -u"
# `system status` / `system push` across every system repo -- see
# ~/projects/station-maintenance/REPOS.md. Pushes need a real terminal.
alias system="$HOME/projects/station-maintenance/bin/system"
alias cronlog="cat ~/Desktop/cronlog"
alias vifmrc="nvim ~/.configure/vifm/vifmrc"
alias todo="cd ~/BRAIN/ && nvim './000-index.md'"
eval $(thefuck --alias)

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="/home/ben/.sdkman"
[[ -s "/home/ben/.sdkman/bin/sdkman-init.sh" ]] && source "/home/ben/.sdkman/bin/sdkman-init.sh"
#[ -f "/home/ben/.ghcup/env" ] && source "/home/ben/.ghcup/env" # ghcup-env

#use the startship prompt
eval "$(starship init zsh)"


export CARDANO_NODE_SOCKET_PATH=~/Projects/iohk/cardano/db/node.socket
[ -f "/home/ben/.ghcup/env" ] && source "/home/ben/.ghcup/env" # ghcup-env
export LD_LIBRARY_PATH=/usr/local/lib:
export NODE_HOME=/home/ben/cardano-my-node
export NODE_BUILD_NUM=7006939
export CARDANO_NODE_SOCKET_PATH=/home/ben/cardano-my-node/cardano-private-network/example/node-bft1/node.sock
nvm use v24
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

export LUA_PATH='~/.config/nvim/lua'

eval "$(mise activate zsh)"
