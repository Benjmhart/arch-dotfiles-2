# xrdb -merge .Xresources

# Retired 2026-07-31: ~/vimwiki no longer exists, so `find` returned nothing and entr
# exited immediately -- this had been a no-op for a long time. ~/bin/vimwikisync (rclone
# push to Google Drive) is likewise dead. Superseded by obsidian-sync.service, which
# syncs ~/BRAIN. Delete this block once that daemon has proven itself.
# find ./vimwiki | entr -adn vimwikisync &


xsetroot -solid midnightblue


# Task 14: apply the monitor layout at login.
# Nothing here or in xmonad.hs used to do this, which is why HDMI-A-1 came up
# unrotated every login and `start2` had to be run by hand. `start2` is exactly
# these two lines in this order.
# Order is load-bearing: double.sh must run BEFORE nitrogen, because
# --set-scaled scales the wallpaper to the CURRENT screen geometry. Run it after
# and the wallpaper is sized for the pre-rotation layout.
# double.sh also carries the --primary flag (task 15) -- without this line the
# primary stays on the disconnected DisplayPort-0 until start2 runs.
bash ~/.screenlayout/double.sh

# Set background image with feh
# feh --bg-scale ~/dotfiles/bg/valley.jpg &
nitrogen --set-scaled --random ~/dotfiles/bg

#screensaver -no-splash &
nm-applet --sm-disable &
picom &
flameshot &
cbatticon &
udiskie & 
clipmenud &
volumeicon & 

# Task 27: Caps Lock becomes an additional Escape.
# MUST run BEFORE `xmodmap` below -- setxkbmap reloads the whole keymap from XKB
# and discards any xmodmap tweaks applied before it. Ordering here is load-bearing,
# not stylistic.
# Note this empties the `lock` modifier entirely: no key can set Caps Lock any more,
# which also means no key can CLEAR it if something else sets it. Task 26's xmobar
# indicator is the only thing that would tell you. Switch to
# `caps:escape_shifted_capslock` to keep Shift+Caps as a real Caps Lock toggle.
setxkbmap -option caps:escape

xmodmap ~/.Xmodmap

exec xmonad
