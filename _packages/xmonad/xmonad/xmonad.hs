import XMonad
import XMonad.StackSet

import XMonad.Actions.EasyMotion

import XMonad.Util.Cursor
import XMonad.Util.EZConfig
import XMonad.Util.Font
import XMonad.Util.Loggers

import XMonad.Hooks.DynamicIcons
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.FadeWindows
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.Rescreen
import XMonad.Hooks.StatusBar
import XMonad.Hooks.StatusBar.PP

import Data.Map.Strict qualified as StrictMap (fromList)
import Data.Monoid (All)
import XMonad.Layout.Accordion (Accordion (Accordion))
import XMonad.Layout.BinaryColumn (BinaryColumn (BinaryColumn))
import XMonad.Layout.BinarySpacePartition (emptyBSP)
import XMonad.Layout.NoBorders (noBorders, smartBorders)
import XMonad.Layout.Renamed (Rename (Replace), renamed)
import XMonad.Layout.ShowWName (showWName)
import XMonad.Layout.Spacing (smartSpacingWithEdge, smartSpacing)
import XMonad.Hooks.FloatConfigureReq (fixSteamFlicker)

---------------------------------------------------------------------------------------------------

main :: IO ()
main =
    xmonad
        . ewmhFullscreen
        . ewmh
        . docks
        . myAutorandrHook
        . myXmobarProp
        $ myConfig

myConfig =
    def
        { focusFollowsMouse = True
        , clickJustFocuses = False
        , normalBorderColor = "#555555"
        , focusedBorderColor = "#F05050"
        , terminal = "alacritty"
        , startupHook = myStartupHook
        , layoutHook = myLayoutHook
        , manageHook = myManageHook
        , logHook = myLogHook
        , handleEventHook = myHandleEventHook
        }
        `additionalKeysP` myAdditionalKeys

---------------------------------------------------------------------------------------------------

myStartupHook :: X ()
myStartupHook = do
    setDefaultCursor xC_left_ptr
    return () >> checkKeymap myConfig myAdditionalKeys

---------------------------------------------------------------------------------------------------

-- TODO:toggleSmartSpacing
myLayoutHook = avoidStruts $ smartBorders $ showWName layouts
  where
    layouts = accordion ||| full ||| bsp
    full = renamed [Replace "Full"] Full
    accordion = renamed [Replace "Accordion"] $
         smartSpacing gap Accordion
    bsp = renamed [Replace "BSP"] $
        smartSpacingWithEdge gap emptyBSP
    gap = 5

---------------------------------------------------------------------------------------------------

myManageHook :: ManageHook
myManageHook =
    composeAll
        [ className =? "Steam" --> doCenterFloat
        , className =? "Pavucontrol" --> doCenterFloat
        , className =? "firefox" <&&> appName =? "Toolkit" --> doCenterFloat
        , className =? "Xfce4-power-manager-settings" --> doCenterFloat
            , isFullscreen --> doFullFloat
            , isDialog --> doCenterFloat
            , isNotification --> doIgnore
            , isKDETrayWindow --> doIgnore
        ]

---------------------------------------------------------------------------------------------------

{- ORMOLU_DISABLE -}
myIcons :: Query [String]
myIcons =
    composeOne
        -- NOTE: WM_CLASS=appName,className
        -- Specific apps with logos
        [ className =? "Spotify"           -?> appIcon "\xf04d3 " -- Spotify
        , className =? "firefox"           -?> appIcon "\xf0239 " -- Firefox
        , className =? "steam"             -?> appIcon "\xf0239 " -- Steam
        , className =? "TelegramDesktop"   -?> appIcon "\xf2c6 " -- Telegram
        -- Specific apps, default icons
        , className =? "Alacritty"         -?> appIcon "\xf489 " -- Generic terminal
        , className =? "Thunar"            -?> appIcon "\xf413 " -- Generic Directory
        , className =? "org.gnome.Weather" -?> appIcon "\xf067e " -- Generic storm
        -- Default denominations and icons
        , appName =? "Navigator"           -?> appIcon "\xf059f " -- Generic internet
        , appName =? "Mail"                -?> appIcon "\xf01f0 " -- Generic letter
        , return $ Just ["\xeb7f "] -- Default: Generic window
        ]
{- ORMOLU_ENABLE -}

myIconFmt :: WorkspaceId -> [String] -> String
myIconFmt wid [] = wid ++ ":" ++ "  "
myIconFmt wid wins = iconsFmtAppend concat wid wins

myIconConfig :: IconConfig
myIconConfig =
    def
        { iconConfigIcons = myIcons
        , iconConfigFmt = myIconFmt
        , iconConfigFilter = iconsGetFocus
        }

---------------------------------------------------------------------------------------------------

myXmobarProp = dynamicSBs barSpawner

barSpawner :: ScreenId -> X StatusBarConfig
barSpawner screen = pure $ xmobarN screen

xmobarN :: ScreenId -> StatusBarConfig
xmobarN (S n) = statusBarPropTo "_XMONAD_LOG" ("xmobar -x " ++ show n) myXmobarPP

myXmobarPP :: X PP
myXmobarPP =
    dynamicIconsPP myIconConfig $
        def
            { ppSep = " • "
            , ppWsSep = ""
            , ppTitle = id
            , ppTitleSanitize = id
            , ppCurrent = white . xmobarBorder "Top" "#8be9fd" 3
            , ppVisible = white
            , ppVisibleNoWindows = Just (const "")
            , ppHidden = grey
            , ppHiddenNoWindows = const ""
            , ppUrgent = red . xmobarBorder "Top" "#8b090d" 4
            , ppOrder = \[ws, l, _, wins] -> [ws, l, wins]
            , ppExtras = [xmobarColorL "lightblue" "" (wrapL "[" "]" (shortenL 25 (logTitle .| logConst "")))]
            }
  where
    white = xmobarColor "#f8f8f2" ""
    grey = xmobarColor "#a8a8a2" ""
    darkgrey = xmobarColor "#686862" ""
    red = xmobarColor "#ff5555" ""

--------------------------------------------------------------------------------

myAdditionalKeys =
    [ ("<XF86AudioLowerVolume>", spawn "amixer sset Master 5%-")
    , ("<XF86AudioRaiseVolume>", spawn "amixer sset Master 5%+")
    , ("<XF86AudioMute>", spawn "amixer sset Master toggle")
    , ("M-f", selectWindow myEasyMotionConfig >>= (`whenJust` windows . focusWindow))
    , ("M-d", selectWindow myEasyMotionConfig >>= (`whenJust` killWindow))
    , ("M-p", spawn "rofi -show")
    , ("M-0", spawn "toggle-comp.sh")
    , ("M-S-4", unGrab *> spawn "scrot -s")
    ]

myEasyMotionConfig :: EasyMotionConfig
myEasyMotionConfig =
    def
        { sKeys =
            PerScreenKeys $
                StrictMap.fromList
                    [ (0, [xK_f, xK_d, xK_s, xK_a])
                    , (1, [xK_h, xK_j, xK_k, xK_l])
                    ]
        , cancelKey = xK_Escape
        }

--------------------------------------------------------------------------------

myAutorandrHook :: XConfig l -> XConfig l
myAutorandrHook = repositionTrays . rerunXrandr
  where
    repositionTrays = addAfterRescreenHook spawnAutorandr
    rerunXrandr = addRandrChangeHook spawnAutorandr
    spawnAutorandr = spawn "autorandr --change"

myFadeHook :: FadeHook
myFadeHook = composeAll [opaque, isUnfocused --> opacity 0.8]

myLogHook :: X ()
myLogHook = do
    fadeWindowsLogHook myFadeHook

---------------------------------------------------------------------------------------------------

myHandleEventHook :: Event -> X All
myHandleEventHook = do
    fadeWindowsEventHook
    fixSteamFlicker

---------------------------------------------------------------------------------------------------

-- TODO: Screen corners?
--

--------------------------------------------------------------------------------
