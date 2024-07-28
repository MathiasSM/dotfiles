import XMonad
import XMonad.StackSet

import XMonad.Actions.EasyMotion

import XMonad.Util.EZConfig
import XMonad.Util.Loggers
import XMonad.Util.Cursor
import XMonad.Util.Font

import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.FadeWindows
import XMonad.Hooks.StatusBar
import XMonad.Hooks.StatusBar.PP

import qualified Data.Map.Strict as StrictMap (fromList)

main :: IO ()
main = xmonad $ ewmhFullscreen $ ewmh $ myXmobarProp $ myConfig
	`additionalKeysP`
		[ ("<XF86AudioLowerVolume>", spawn "amixer sset Master 5%-")
		, ("<XF86AudioRaiseVolume>", spawn "amixer sset Master 5%+")
		, ("<XF86AudioMute>", spawn "amixer sset Master toggle")
		, ("M-f", selectWindow myEasyMotionConfig >>= (`whenJust` windows . focusWindow))
		, ("M-d", selectWindow myEasyMotionConfig >>= (`whenJust` killWindow))
		]

myEasyMotionConfig = def
	{ sKeys = PerScreenKeys $ StrictMap.fromList $
		[ (0, [xK_f, xK_d, xK_s, xK_a])
		, (1, [xK_h, xK_j, xK_k, xK_l])
		]
	, cancelKey = xK_Escape
	}

myConfig = def
	{ manageHook = myManageHook
	, logHook = fadeWindowsLogHook myFadeHook
	, handleEventHook = fadeWindowsEventHook
	, startupHook = setDefaultCursor xC_left_ptr
	, terminal = "alacritty"
	}

myManageHook :: ManageHook
myManageHook = composeAll
	[ className =? "Gimp" --> doFloat
	, isDialog            --> doFloat
	]

myFadeHook :: FadeHook
myFadeHook = composeAll
	[ opaque
	, isUnfocused --> opacity 0.9
	]


myXmobarProp = dynamicEasySBs barSpawner

barSpawner :: ScreenId -> IO StatusBarConfig
barSpawner screen = pure $ xmobar_n screen

xmobar_n (S n) = statusBarPropTo ("_XMONAD_LOG") ("xmobar -x " ++ show n) (pure myXmobarPP)


myXmobarPP :: PP
myXmobarPP = def
    { ppSep             = " • "
    , ppWsSep           = ""
    , ppTitle           = xmobarStrip
    , ppTitleSanitize   = xmobarStrip
    , ppCurrent         = white . xmobarBorder "Top" "#8be9fd" 3
    , ppVisible	        = white
    , ppHidden          = grey
    , ppHiddenNoWindows = darkgrey
    , ppUrgent          = red . xmobarBorder "Top" "#8b090d" 4
    , ppOrder           = \[ws, l, _, wins] -> [ws, l, wins]
    , ppExtras          = [xmobarColorL "lightblue" "" $ wrapL "[" "]" $ shortenL 40 (logTitle .| logConst "")]
    }
  where
    blue, lowWhite, magenta, red, white, yellow :: String -> String
    magenta  = xmobarColor "#ff79c6" ""
    blue     = xmobarColor "#bd93f9" ""
    white    = xmobarColor "#f8f8f2" ""
    grey     = xmobarColor "#a8a8a2" ""
    darkgrey = xmobarColor "#686862" ""
    yellow   = xmobarColor "#f1fa8c" ""
    red      = xmobarColor "#ff5555" ""
    lowWhite = xmobarColor "#bbbbbb" ""
