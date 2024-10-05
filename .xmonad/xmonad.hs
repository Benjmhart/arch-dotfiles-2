-------------------------------------------------------------------
-- ~/.xmonad/xmonad.hs
-- valirt@gmail.cojjjdate syntax: `ghcid` or `xmonad --recompile`
{-# LANGUAGE NoMonomorphismRestriction #-} -------------------------------------------------------------------
import XMonad
import XMonad.Actions.SpawnOn (spawnOn)
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
    , manageHook = myManageHook <+> manageDocks 
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
    [ ]

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



-- copyq is summoned with Meta + shift + b
-- dmenu launch is summoned with Meta + p
myStartupHook = do
  spawnOnce "alacritty &"
  spawnOnce "copyq &"
  -- spawnOnce "clipmenud &"
  spawnOnce "stalonetray &"

-- wishlist 
-- 3. hotkey for tile screenshot
-- 4. hotkey to cycle through workspaces
