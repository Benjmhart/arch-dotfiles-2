#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
PS1='[\u@\h \W]\$ '

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="/home/ben/.sdkman"
[[ -s "/home/ben/.sdkman/bin/sdkman-init.sh" ]] && source "/home/ben/.sdkman/bin/sdkman-init.sh"
# Replaced 2026-08-02. This line and one below it were two hardcoded PATH
# snapshots of 6442 and 6463 characters -- 275 and 276 entries -- written by an
# installer that captured an already-duplicated PATH and froze it into this file.
# Because ~/.bash_profile sources this file and ~/.zshrc sources ~/.bash_profile,
# they were the origin of every stale entry in this machine's PATH, including
# directories that have not existed for years. See station-maintenance/beast-arch.
#
# Everything real that they contributed comes from elsewhere already: system
# directories from /etc/profile, the java bin from sdkman-init.sh sourced above,
# ghcup and cabal from their own env files. Only the user bins need restating,
# and only for bash -- zsh gets them from ~/.zshrc, which also sets
# `typeset -U path PATH` so duplicates cannot accumulate again.
PATH="$HOME/bin:$HOME/.local/bin:$HOME/.cargo/bin:$HOME/go/bin:$PATH"
export NODE_HOME=/home/ben/cardano-my-node
export CARDANO_NODE_SOCKET_PATH=/home/ben/cardano-my-node/cardano-private-network/example/node-bft1/node.sock
export NODE_BUILD_NUM=7006939
export LD_LIBRARY_PATH=/usr/local/lib:/usr/local/lib:
export NODE_HOME=/home/ben/cardano-my-node
