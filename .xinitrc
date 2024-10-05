# xrdb -merge .Xresources

# vimwiki sync on edit
find ./vimwiki | entr -adn vimwikisync &


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
