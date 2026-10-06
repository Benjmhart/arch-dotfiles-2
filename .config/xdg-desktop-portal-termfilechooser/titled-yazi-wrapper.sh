#!/bin/sh
# The portal's file chooser: yazi in a floating Alacritty, titled so xmobar reads
# "Save as: <suggested name>" while saving. Args from the portal:
# multiple directory save path out debug.
#
# Replaces the packaged yazi-wrapper.sh (v1.4.3) instead of wrapping it: that one splices
# the path into an `sh -c` string escaping only double quotes, so a suggested filename
# with backticks or $(...) -- which a website controls -- runs as a command. Here every
# value goes to alacritty/yazi as its own argv entry; no shell re-parses anything.
# station-maintenance beast-arch task 72.
multiple=$1 directory=$2 save=$3 path=$4 out=$5
[ "$6" = 1 ] && set -x
if [ "$save" = 1 ]; then title="Save as: ${path##*/}"; else title="Open file"; fi
term() { alacritty --class termfilechooser --title "$title" -e yazi "$@"; }

if [ "$directory" = 1 ]; then
  term --chooser-file="$out" --cwd-file="$out.1" "$path"
  # a directory picked by quitting inside it is in the cwd file, not the chooser file
  if [ ! -s "$out" ] && [ -s "$out.1" ]; then cat "$out.1" > "$out"; fi
  rm -f "$out.1"
else
  term --chooser-file="$out" "$path"   # "multiple" needs no flag: yazi returns every selected file
fi

# Saving: the portal pre-creates $path holding its instructions. If it was not the file
# chosen (cancelled, or another file picked), it is litter -- one was committed into a
# repo on 2026-10-04. Removed only while it still starts with the portal's marker line,
# so a real file at that path is never touched. A placeholder moved elsewhere and then
# abandoned is not tracked.
if [ "$save" = 1 ] && ! grep -qxF -- "$path" "$out" 2>/dev/null \
   && head -n1 -- "$path" 2>/dev/null | grep -qF '* xdg-desktop-portal-termfilechooser instructions *'; then
  rm -f -- "$path"
fi
