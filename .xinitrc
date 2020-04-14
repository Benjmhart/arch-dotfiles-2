xrdb -merge .Xresources


xsetroot -solid midnightblue


# Set background image with feh
# feh --bg-scale ~/dotfiles/bg/valley.jpg &
nitrogen --set-scaled --random ~/dotfiles/bg

#screensaver -no-splash &
nm-applet --sm-disable &
picom &
flameshot &
cbatticon &
xfce4-power-manager &
udiskie & 
volumeicon & 
xmodmap ~/.Xmodmap

exec xmonad
