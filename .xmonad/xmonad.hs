-------------------------------------------------------------------
-- ~/.xmonad/xmonad.hs
-- valirt@gmail.cojjjdate syntax: `ghcid` or `xmonad --recompile`
{-# LANGUAGE NoMonomorphismRestriction #-} -------------------------------------------------------------------
import XMonad
import XMonad.Actions.SpawnOn (spawnOn, manageSpawn)
import XMonad.Actions.WindowGo (runOrRaise)
import XMonad.Hooks.DynamicLog
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
  xmproc <- spawnPipe "/usr/bin/xmobar ~/.xmobarrc"
  xmonad $ def 
    { terminal = "alacritty"
    , manageHook = manageSpawn <+> myManageHook <+> manageDocks
    , startupHook = myStartupHook
    , layoutHook = avoidStruts $ layoutHook def
    , logHook = dynamicLogWithPP xmobarPP 
      { ppOutput = hPutStrLn xmproc
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
-- unfortunately pacmixer went out of sync with libgnustep
-- modKVolume = ((winSuperMask, xK_v), spawn  "alacritty --command pacmixer")
modKVolume = ((winSuperMask, xK_v), spawn  "pavucontrol")
modKWally = ((winSuperMask .|. shiftMask, xK_w), spawn  "wally")
modKEmoji = ((winSuperMask .|. shiftMask, xK_m), spawn "bemoji")

-- textEmail = toTextKey xK_e "Benjmhart@gmail.com"
-- textName = toTextKey xK_n "Ben Hart"

-- toTextKey :: MonadIO m => Word64 -> String -> ((KeyMask, KeySym), m ())
-- toTextKey k t = ((winSuperMask .|. altMask .|. controlMask, k), spawn ("sleep 2 && xdotool type " <> t))

modKClipboard = ((winSuperMask, xK_b), spawn "clipmenu")
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

