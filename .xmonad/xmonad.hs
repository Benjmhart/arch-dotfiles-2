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
  -- One xmobar per monitor THAT ACTUALLY EXISTS, 2026-08-28 (carbon task 4).
  --
  -- Was two hardcoded lines, `-x 0` and `-x 1`, added 2026-08-07 for beast-arch's
  -- two monitors. The old comment here claimed that if a monitor were absent "that
  -- bar simply has nowhere to draw". That was wrong, and it was wrong on carbon for
  -- three weeks: carbon has ONE screen, and the `-x 1` bar did not fail and did not
  -- go anywhere else -- it fell back onto screen 0 and drew EXACTLY on top of the
  -- other one. Both windows measured 1920x17 at +0+0. Invisible, because ppOutput
  -- below writes the same line to both, so the only cost was that every `Run Com`
  -- in ~/.xmobarrc ran twice -- including the battery script added in carbon
  -- task 3.
  --
  -- countScreens asks X how many there are, so this is right on both machines
  -- without a hostname anywhere: beast-arch still gets its two bars, carbon gets
  -- one. `XMonad.Layout.IndependentScreens` was already imported.
  --
  -- `max 1` is deliberate insurance, not decoration. If countScreens ever answered
  -- 0 the list would be empty and the session would come up with NO bar at all,
  -- which is a far worse failure than the duplicate this replaces, and a silent
  -- one. It should not be reachable while X is running; it costs nothing to make
  -- sure.
  --
  -- `-x N` is still a positional Xinerama index: on beast-arch 0 = HDMI-A-0
  -- (1920x1080, left) and 1 = HDMI-A-1 (the vertical 1080x1920). Reorder the
  -- monitors and the bars follow the new order silently. ~/.xmobarrc is shared by
  -- all of them and therefore says `position = Top`, not `OnScreen n` -- that would
  -- override the flag and put every bar on the same screen.
  screenCount <- countScreens :: IO Int
  xmprocs <- mapM (\i -> spawnPipe ("/usr/bin/xmobar -x " ++ show i ++ " ~/.xmobarrc"))
                  [0 .. max 1 screenCount - 1]
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
      -- Same line to every bar. Each xmobar owns its own stdin, so one write per
      -- process is required -- writing once would leave the others blank.
      { ppOutput = \s -> mapM_ (\h -> hPutStrLn h s) xmprocs
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

-- beast-arch, 2026-08-25: moved off mod-b (Super+B) to Alt+B. The Moonlander
-- emits Super when the spacebar is HELD, so Super+B fired whenever the nvim
-- leader (spacebar) was held over b. NOTE: `altMask` defined at the top of this
-- file is mod3Mask, which is ISO_Level5_Shift on this machine, NOT Alt --
-- verified with `xmodmap -pm`. Alt is mod1Mask. Do not "tidy" this to altMask.
-- Known trade-off: xmonad grabs this globally, so Alt+B no longer reaches
-- readline (it was backward-word in zsh).
modKClipboard = ((mod1Mask, xK_b), spawn "clipmenu")

-- beast-arch task 34. mod-a toggles the default audio sink between the
-- motherboard analog jack and the RX 580's HDMI audio, and drags already-playing
-- streams across with it -- setting the default alone moves NEW streams only.
-- mod-a is not a stock XMonad binding, so this takes nothing silently the way
-- mod-m did above. audio-toggle lives in ~/.local/bin, which IS on xmonad's
-- inherited PATH (checked in /proc/<xmonad>/environ, not assumed).
modKAudioToggle = ((winSuperMask, xK_a), spawn "audio-toggle")
-- Super+d = "do not disturb": hide/unhide desktop notifications, 2026-09-05.
-- `quiet` lives in ~/.local/bin alongside audio-toggle, so the same PATH note
-- above applies. Toggling OFF releases whatever was held; `quiet clear` in a
-- terminal is the variant that discards without popping a stack of them.
--
-- xK_d chosen because it is free in BOTH myKeys and xmonad's defaults. Note the
-- warning below about additionalKeys overriding silently: xK_n would have taken
-- mod-n (refresh) without saying so.
modKQuiet = ((winSuperMask, xK_d), spawn "quiet toggle")
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
    , modKQuiet
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

