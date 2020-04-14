#!/usr/bin/env bash

set -o errexit
set -o nounset

main() {
  killall stalonetray
  bash ~/.screenlayout/wide.sh
  nohup stalonetray --config ~/.stalonetrayrc 2>&1 /dev/null &
  nitrogen --set-scaled --random ~/dotfiles/bg & 
}

main
