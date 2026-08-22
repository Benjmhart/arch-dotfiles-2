# xrdb -merge .Xresources

# Retired 2026-07-31: ~/vimwiki no longer exists, so `find` returned nothing and entr
# exited immediately -- this had been a no-op for a long time. ~/bin/vimwikisync (rclone
# push to Google Drive) is likewise dead. Superseded by obsidian-sync.service, which
# syncs ~/BRAIN. Delete this block once that daemon has proven itself.
# find ./vimwiki | entr -adn vimwikisync &


# Push DISPLAY/XAUTHORITY into the systemd user manager and the D-Bus activation
# environment (2026-08-22).
#
# Neither is inherited here. A display manager would import them at login; startx
# does not, so `systemctl --user show-environment` came up with no DISPLAY at all
# while every shell had DISPLAY=:0. Anything D-Bus-activated therefore started
# blind to X.
#
# The symptom this fixes: gnome-keyring could not unlock the login keyring because
# gcr-prompter is D-Bus-activated and died instantly with "cannot open display".
# The daemon then refused to export /org/freedesktop/secrets/collection/login, and
# secret-tool reported "Object does not exist at path ..." -- which reads like a
# missing keyring and is really a prompt that could never be drawn.
#
# MUST run before anything that talks to the secret service. --systemd updates the
# systemd user environment as well as the D-Bus one; both are needed, because the
# prompter is activated by dbus but launched as a systemd user unit.
dbus-update-activation-environment --systemd DISPLAY XAUTHORITY

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
#
# GUARDED BY HOSTNAME (2026-08-05). .xinitrc is tracked in the dotfiles repo and
# travels to every machine, but double.sh names outputs that exist only here
# (HDMI-A-0 / HDMI-A-1, second monitor rotated right). Running it elsewhere
# would fail, or worse, half-apply a layout for hardware that is not present.
# Read /etc/hostname rather than calling `hostname` -- the inetutils `hostname`
# binary is NOT installed on this box (checked 2026-08-05), so a `hostname`-based
# guard would silently never match and the layout would stop being applied here.
if [ "$(cat /etc/hostname 2>/dev/null)" = "beast-arch" ] && [ -r "$HOME/.screenlayout/double.sh" ]; then
  sh "$HOME/.screenlayout/double.sh"
fi

# Set the background. Wallpapers moved out of the dotfiles into their own repo
# on 2026-08-15 (beast-arch task 35) -- this path is the live reference, and a
# machine without the wallpapers repo cloned comes up with no wallpaper at all.
# The old feh line is dropped rather than repointed; nitrogen is the setter and
# task 14's double.sh must run BEFORE it, which it does above.
#
# zoom-fill, NOT scaled. In nitrogen "scaled" means stretch-to-fit IGNORING the
# aspect ratio -- on this box HDMI-A-1 is rotated to 1080x1920, so a landscape
# image was being squeezed into a portrait head and looked wrong. zoom-fill
# preserves the aspect ratio and crops the overflow instead. Changed 2026-08-15
# after Ben reported the desktop looking pixelated; beast-arch task 35.
nitrogen --set-zoom-fill --random ~/projects/wallpapers

# Japanese input (fcitx5 + mozc). Guarded like the monitor block above: this
# file travels in the dotfiles repo, and on a machine without fcitx5 the env
# vars would make GTK/Qt apps hunt for a missing input module.
# Exports must happen BEFORE any app launches below (and before exec xmonad) --
# apps read *_IM_MODULE/XMODIFIERS only at startup.
if command -v fcitx5 >/dev/null 2>&1; then
  export GTK_IM_MODULE=fcitx
  export QT_IM_MODULE=fcitx
  export XMODIFIERS=@im=fcitx
  # XDG_CONFIG_HOME is set by .zshrc (line 50), which this file never sources,
  # so fcitx5 started here would read ~/.config/fcitx5 -- an empty path -- and
  # silently fall back to stock defaults: no mozc in the group, Ctrl+space
  # trigger, and typing that stays romaji. Set it for fcitx5 ONLY; exporting it
  # session-wide would repoint every other app launched below at a different
  # config tree.
  XDG_CONFIG_HOME="$HOME/.configure" fcitx5 -d
fi

#screensaver -no-splash &
nm-applet --sm-disable &
picom &
flameshot &
cbatticon &
udiskie & 
clipmenud &
volumeicon &

# Handy (dictation, mod4+s) and Meetily (meeting transcription). Added 2026-08-11.
#
# WHY THESE ARE HERE AND NOT LEFT TO XDG AUTOSTART. Handy ships
# ~/.config/autostart/Handy.desktop, and systemd does generate
# app-Handy@autostart.service from it -- but that unit is only pulled in by
# xdg-desktop-autostart.target, which nothing on this box ever starts: .xinitrc
# execs xmonad directly, with no desktop environment to activate the target.
# Verified 2026-08-11 after a reboot: the target and the unit were both
# `inactive`, WantedBy was empty, and neither app was running. Handy had been
# started by hand every session without anyone noticing. This file is already
# the de-facto autostart mechanism here, so it is where they belong.
#
# Guarded by path, like the fcitx5 and monitor blocks above -- .xinitrc travels
# in the dotfiles repo and neither binary exists on other machines.
[ -x /usr/bin/handy ] && /usr/bin/handy &

# Meetily writes recordings to ./meetily-recordings, RELATIVE TO ITS CWD. It was
# once launched from a repo checkout and dropped recordings inside that repo, so
# the cd is load-bearing, not decorative. Subshell so it does not move the cwd
# for anything else started from this file.
[ -x "$HOME/.local/bin/meetily" ] && ( cd "$HOME" && exec "$HOME/.local/bin/meetily" ) &

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

# SSH_ASKPASS (2026-08-22): exported here as well as in .zshrc so that programs
# xmonad starts directly -- Emacs/Forge, Vivaldi, anything not descended from a
# shell -- inherit it. .zshrc only reaches processes that came from a shell, and
# a GUI app asking for an ssh passphrase is exactly the case that has no terminal.
# See the longer note in .zshrc for why SSH_ASKPASS_REQUIRE is left unset.
# Guarded by path: x11-ssh-askpass is not installed on every machine this file
# travels to, and a dangling SSH_ASKPASS is worse than none.
[ -x /usr/lib/ssh/ssh-askpass ] && export SSH_ASKPASS=/usr/lib/ssh/ssh-askpass

exec xmonad
