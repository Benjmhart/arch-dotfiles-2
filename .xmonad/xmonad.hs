-------------------------------------------------------------------
-- ~/.xmonad/xmonad.hs
-- valirt@gmail.cojjjdate syntax: `ghcid` or `xmonad --recompile`
{-# LANGUAGE NoMonomorphismRestriction #-} -------------------------------------------------------------------
import XMonad
import XMonad.Actions.SpawnOn (spawnOn, manageSpawn)
import XMonad.Actions.WindowGo (runOrRaise)
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.EwmhDesktops (ewmh)
import XMonad.Hooks.ManageDocks
import XMonad.StackSet as W
import XMonad.Util.Run (spawnPipe)
import XMonad.Util.EZConfig (additionalKeys)
import XMonad.Util.SpawnOnce
import System.IO 
import XMonad.Layout.IndependentScreens
import GHC.Word (Word64)

winSuperMask = mod4Mask
altMask = mod3Mask
main = do
  -- One xmobar per monitor, 2026-08-07. `-x N` is a Xinerama index, taken from
  -- `xrandr --listmonitors`: 0 = HDMI-A-0 (1920x1080, left), 1 = HDMI-A-1 (the
  -- vertical 1080x1920). Both read the same ~/.xmobarrc, which therefore says
  -- `position = Top` rather than `OnScreen n` -- otherwise the config would
  -- override the flag and both bars would land on the same screen.
  --
  -- The index is positional: if the monitor layout is ever reordered, this points
  -- at the wrong screen silently rather than failing. If a monitor is absent, that
  -- bar simply has nowhere to draw -- it does not take the other one down.
  xmproc0 <- spawnPipe "/usr/bin/xmobar -x 0 ~/.xmobarrc"
  xmproc1 <- spawnPipe "/usr/bin/xmobar -x 1 ~/.xmobarrc"
  -- `ewmh` publishes _NET_CLIENT_LIST / _NET_ACTIVE_WINDOW / _NET_CURRENT_DESKTOP.
  -- Without it xmonad advertises nothing, and anything that enumerates windows --
  -- notably Zoom's "Share Screen" window picker (task 15) -- sees an empty list.
  -- xmonad-contrib 0.16 exports `ewmh` but NOT `ewmhFullscreen`; the fullscreen
  -- half is a separate `fullscreenEventHook` in handleEventHook, left off on
  -- purpose so this change has one variable.
  xmonad $ ewmh $ def
    { terminal = "alacritty"
    , manageHook = manageSpawn <+> myManageHook <+> manageDocks
    , startupHook = myStartupHook
    , layoutHook = avoidStruts $ layoutHook def
    , logHook = dynamicLogWithPP xmobarPP
      -- Same line to both bars. Each xmobar owns its own stdin, so one write per
      -- process is required -- writing once would leave the second bar blank.
      { ppOutput = \s -> hPutStrLn xmproc0 s >> hPutStrLn xmproc1 s
      , ppTitle = xmobarColor "green" "" . shorten 50
      }
    , handleEventHook = handleEventHook def <+> docksEventHook
    , modMask = winSuperMask -- rebind mod to the windows key
    } `additionalKeys` 
      myKeys

myManageHook
  = composeAll
    -- Rambox is Electron and reparents its window after mapping, which defeats
    -- spawnOnOnce/manageSpawn (it landed on ws 1 instead of 5 after a reboot).
    -- Matching on the window's own WM_CLASS is reliable where the spawner isn't.
    -- xprop reports both "Rambox" and "rambox" as res_class, so match either.
    [ className =? "Rambox" --> doShift "5"
    , className =? "rambox" --> doShift "5"
    ]

printscreenFlameshot = ((noModMask, xK_Print), spawn "flameshot gui")
modKKeypass = ((winSuperMask .|. shiftMask, xK_k), spawn "keepassxc")
-- pacmixer's libgnustep breakage is fixed as of 0.6.4-2 -- verified 2026-07-31, it
-- links against libgnustep-base.so.1.31 and enumerates PulseAudio devices fine.
-- (pavucontrol was the stopgap, and was never actually installed on this box.)
modKVolume = ((winSuperMask, xK_v), spawn  "alacritty --command pacmixer")
modKWally = ((winSuperMask .|. shiftMask, xK_w), spawn  "wally")
-- Super+M, not Super+Shift+M (2026-08-24, Ben's request -- it is reached one-handed).
-- KNOWN COST: mod-m is a stock XMonad binding, `windows W.focusMaster`, and
-- additionalKeys OVERRIDES rather than conflicts, so this takes it silently. If you
-- ever want focus-master back, mod-<Return> already swaps master and focused, and
-- mod-j/mod-k walk the stack.
--
-- bemoji downloads the Unicode emoji list to ~/.local/share/bemoji on FIRST run
-- only, so the very first press pauses and an offline first press fails. It picks
-- dmenu (first installed in its picker order) and xclip for the paste.
modKEmoji = ((winSuperMask, xK_m), spawn "bemoji")

-- textEmail = toTextKey xK_e "Benjmhart@gmail.com"
-- textName = toTextKey xK_n "Ben Hart"

-- toTextKey :: MonadIO m => Word64 -> String -> ((KeyMask, KeySym), m ())
-- toTextKey k t = ((winSuperMask .|. altMask .|. controlMask, k), spawn ("sleep 2 && xdotool type " <> t))

modKClipboard = ((winSuperMask, xK_b), spawn "clipmenu")

-- beast-arch task 34. mod-a toggles the default audio sink between the
-- motherboard analog jack and the RX 580's HDMI audio, and drags already-playing
-- streams across with it -- setting the default alone moves NEW streams only.
-- mod-a is not a stock XMonad binding, so this takes nothing silently the way
-- mod-m did above. audio-toggle lives in ~/.local/bin, which IS on xmonad's
-- inherited PATH (checked in /proc/<xmonad>/environ, not assumed).
modKAudioToggle = ((winSuperMask, xK_a), spawn "audio-toggle")
-- alt is mod1Mask
modKScreenmap = [((mod4Mask .|. mod1Mask, key), screenWorkspace sc >>= flip whenJust (windows . f))
  | (key, sc) <- zip [xK_w, xK_e, xK_r] [1, 0, 2]
  , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]
myKeys 
  = [ printscreenFlameshot
    , modKKeypass
    , modKEmoji
    , modKVolume
    , modKClipboard
    , modKAudioToggle
    -- , textEmail
    -- , textName
    ]
    -- , modKScreenmap



-- dmenu launch is summoned with Meta + p
myStartupHook = do
  spawnOnce "alacritty &"
  -- spawnOnce "copyq &" --remove? use clipmenu now
  -- spawnOnce "clipmenud &"
  spawnOnce "stalonetray &"
  -- Session apps, each pinned to a workspace.
  -- spawnOnOnce = place on workspace + don't respawn on xmonad restart.
  -- Requires manageSpawn in manageHook (above) or the workspace is ignored.
  spawnOnOnce "9" "alacritty -e todo"   -- todo = ~/.local/bin/todo (nvim on the BRAIN index)
  -- Obsidian dropped 2026-07-31: obsidian-sync.service now syncs ~/BRAIN headlessly,
  -- so the desktop app no longer needs to be running. Launch it by hand when you
  -- actually want the GUI -- but if you do, leave Sync DISABLED inside the app;
  -- two sync clients on one device is unsupported.
  spawnOnOnce "5" "rambox"
  spawnOnOnce "4" "vivaldi"
  -- herdr = terminal multiplexer / workspace manager for coding agents.
  -- NOTE: ~/.local/bin/herdr is a self-distributed binary that updates itself
  -- (`herdr update`). It is NOT tracked here and NOT installed by pacman/AUR, so
  -- arch-bootstrap installs it in stage 25 -- otherwise this line fails at login
  -- with "command not found" on a rebuilt machine, the way `todo` would have.
  spawnOnOnce "2" "alacritty -e herdr"

