# qutebrowser config. Tracked in the dotfiles; settings changed in the UI
# (autoconfig.yml) are deliberately NOT loaded, so this file is the whole truth.
# Started 2026-10-03 for a trial on micro (station-maintenance micro task 5);
# Vivaldi stays the default browser until Ben decides.
import os
import subprocess

config.load_autoconfig(False)

# DuckDuckGo everywhere (beast-arch task 73). `:open foo` and the start page both use it.
c.url.searchengines = {"DEFAULT": "https://duckduckgo.com/?q={}"}
c.url.start_pages = ["https://duckduckgo.com"]
c.url.default_page = "https://duckduckgo.com"

c.colors.webpage.preferred_color_scheme = "dark"

# Brave's adblock engine (needs python-adblock) plus hosts lists.
c.content.blocking.method = "both"

# Lean hosts only (~/bin/lean-host: micro, 3.5 GiB). One renderer per site rather
# than per tab costs some isolation for a lot of RAM; low-end mode is Chromium's own
# memory-saving switch, which would otherwise only engage below ~1 GB free.
# Both are read at startup, so a change needs a full restart, not :config-source.
if subprocess.call([os.path.expanduser("~/bin/lean-host")]) == 0:
    c.qt.chromium.process_model = "process-per-site"
    c.qt.chromium.low_end_device_mode = "always"

# File picker: the same yazi-in-floating-Alacritty as every portal app (beast-arch task 72).
# qutebrowser does not ask the portal, so call the portal's wrapper directly. Its args:
# multiple directory save path out -- each its own argv entry, nothing goes through a shell.
_yazi = os.path.expanduser("~/.config/xdg-desktop-portal-termfilechooser/titled-yazi-wrapper.sh")
c.fileselect.handler = "external"
c.fileselect.single_file.command = [_yazi, "0", "0", "0", os.path.expanduser("~"), "{}"]
c.fileselect.multiple_files.command = [_yazi, "1", "0", "0", os.path.expanduser("~"), "{}"]
c.fileselect.folder.command = [_yazi, "0", "1", "0", os.path.expanduser("~"), "{}"]
# Ctrl+O: open local file(s) via yazi (userscripts/open-file). In a download's location
# prompt, Ctrl+O picks the folder in yazi too (qutebrowser's own Alt+E does the same).
config.bind("<Ctrl-o>", "spawn --userscript open-file")
config.bind("<Ctrl-o>", "prompt-fileselect-external", mode="prompt")
