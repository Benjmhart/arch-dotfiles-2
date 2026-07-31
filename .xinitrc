# xrdb -merge .Xresources

# Retired 2026-07-31: ~/vimwiki no longer exists, so `find` returned nothing and entr
# exited immediately -- this had been a no-op for a long time. ~/bin/vimwikisync (rclone
# push to Google Drive) is likewise dead. Superseded by obsidian-sync.service, which
# syncs ~/BRAIN. Delete this block once that daemon has proven itself.
# find ./vimwiki | entr -adn vimwikisync &


xsetroot -solid midnightblue


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

xmodmap ~/.Xmodmap

exec xmonad
