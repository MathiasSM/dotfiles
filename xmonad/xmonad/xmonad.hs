import XMonad
import XMonad.StackSet

import XMonad.Actions.EasyMotion

import XMonad.Util.EZConfig
import XMonad.Util.Loggers
import XMonad.Util.Cursor
import XMonad.Util.Font

import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.DynamicIcons
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.FadeWindows
import XMonad.Hooks.Rescreen
import XMonad.Hooks.StatusBar
import XMonad.Hooks.StatusBar.PP

import qualified Data.Map.Strict as StrictMap (fromList)

--------------------------------------------------------------------------------



--------------------------------------------------------------------------------
-- WM_CLASS=appName,className
myIcons :: Query [String]
myIcons = composeOne
  -- Specific apps with logos
  [ className =? "Spotify" -?> appIcon "\xf04d3 " -- Spotify
  , className =? "firefox" -?> appIcon "\xf0239 " -- Firefox
  , className =? "steam" -?> appIcon "\xf0239 " -- Steam
  , className =? "TelegramDesktop" -?> appIcon "\xf2c6 " -- Telegram
  -- Specific apps, default icons
  , className =? "Alacritty" -?> appIcon "\xf489 " -- Generic terminal
  , className =? "Thunar" -?> appIcon "\xf413 " -- Generic Directory
  , className =? "org.gnome.Weather" -?> appIcon "\xf067e " -- Generic storm
  -- Default denominations and icons
  , appName =? "Navigator" -?> appIcon "\xf059f " -- Generic internet
  , appName =? "Mail" -?> appIcon "\xf01f0 " -- Generic letter
  , return $ Just ["\xeb7f "] -- Default: Generic window
  ]

myIconFmt :: WorkspaceId -> [String] -> String
myIconFmt wid [] = wid ++ ":" ++ "  "
myIconFmt wid wins = iconsFmtAppend concat wid wins

myIconConfig :: IconConfig
myIconConfig = def
    { iconConfigIcons = myIcons
    , iconConfigFmt = myIconFmt
    , iconConfigFilter = iconsGetFocus
    }

barSpawner :: ScreenId -> X StatusBarConfig
barSpawner screen = pure $ xmobar_n screen

xmobar_n (S n) = statusBarPropTo ("_XMONAD_LOG") ("xmobar -x " ++ show n) myXmobarPP

myXmobarPP = dynamicIconsPP myIconConfig $ def
    { ppSep             = " • "
    , ppWsSep           = ""
    , ppTitle           = id
    , ppTitleSanitize   = id
    , ppCurrent         = white . xmobarBorder "Top" "#8be9fd" 3
    , ppVisible         = white
    , ppVisibleNoWindows= Just (const "")
    , ppHidden          = grey
    , ppHiddenNoWindows = const ""
    , ppUrgent          = red . xmobarBorder "Top" "#8b090d" 4
    , ppOrder           = \[ws, l, _, wins] -> [ws, l, wins]
    , ppExtras          = [xmobarColorL "lightblue" "" $ wrapL "[" "]" $ shortenL 25 (logTitle .| logConst "")]
    }
  where
    white    = xmobarColor "#f8f8f2" ""
    grey     = xmobarColor "#a8a8a2" ""
    darkgrey = xmobarColor "#686862" ""
    red      = xmobarColor "#ff5555" ""

myXmobarProp = dynamicEasySBs barSpawner
--------------------------------------------------------------------------------


myAdditionalKeys = 
    [ ("<XF86AudioLowerVolume>", spawn "amixer sset Master 5%-")
    , ("<XF86AudioRaiseVolume>", spawn "amixer sset Master 5%+")
    , ("<XF86AudioMute>", spawn "amixer sset Master toggle")
    , ("M-f", selectWindow myEasyMotionConfig >>= (`whenJust` windows . focusWindow))
    , ("M-d", selectWindow myEasyMotionConfig >>= (`whenJust` killWindow))
    , ("M-/", spawn "get-active-xprops.sh")
    , ("M-p", spawn "rofi -show")
    , ("M-0", spawn "toggle-compositor.sh")
    ]

myEasyMotionConfig :: EasyMotionConfig
myEasyMotionConfig = def
    { sKeys = PerScreenKeys $ StrictMap.fromList $
        [ (0, [xK_f, xK_d, xK_s, xK_a])
        , (1, [xK_h, xK_j, xK_k, xK_l])
        ]
    , cancelKey = xK_Escape
    }

--------------------------------------------------------------------------------

myRandrChangeHook :: X()
myRandrChangeHook = spawn "autorandr --change"

myAutorandrHook = rescreenHook $ def
    { afterRescreenHook = spawn "autorandr --change"
    , randrChangeHook = spawn "autorandr --change" }

myFadeHook :: FadeHook
myFadeHook = composeAll
    [ opaque
    , isUnfocused --> opacity 0.9
    , isFloating --> opacity 1
    ]
    
myLogHook = fadeWindowsLogHook myFadeHook

myManageHook = composeAll
    [ className =? "Steam"                        --> doCenterFloat
    , className =? "Gimp"                         --> doCenterFloat
    , className =? "MPlayer"                      --> doCenterFloat
    , className =? "Pavucontrol"                  --> doCenterFloat
    , className =? "firefox" <&&> appName =? "Toolkit" --> doCenterFloat
    , className =? "Xfce4-power-manager-settings" --> doCenterFloat
    , isFullscreen        --> doFullFloat
    , isDialog            --> doFloat
    ]

myEventHook = fadeWindowsEventHook
-- TODO: Screen corners?
--

myStartupHook = setDefaultCursor xC_left_ptr
--------------------------------------------------------------------------------

main :: IO ()
main = xmonad
    . ewmhFullscreen 
    . ewmh 
    . myAutorandrHook
    . myXmobarProp 
    . docks
    $ def 
        { focusFollowsMouse = True
        , clickJustFocuses = False
        , normalBorderColor = "#555555"
        , focusedBorderColor = "#F05050"
        , manageHook = myManageHook
        , logHook = myLogHook
        , handleEventHook = myEventHook
        , startupHook = myStartupHook
        , terminal = "alacritty"
        } `additionalKeysP` myAdditionalKeys
        
