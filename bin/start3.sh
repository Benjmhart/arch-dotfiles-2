#!/usr/bin/env bash

set -o errexit
set -o nounset

main() {
  killall stalonetray
  bash ~/.screenlayout/tripleThreat.sh
  nohup stalonetray --config ~/.stalonetrayrc &
  nitrogen --set-scaled --random ~/dotfiles/bg &
}

main
