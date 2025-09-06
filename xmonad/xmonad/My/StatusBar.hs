module My.StatusBar (addStatusBar) where

import XMonad
import XMonad.Hooks.DynamicIcons
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.StatusBar
import XMonad.Hooks.StatusBar.PP
import XMonad.Prelude
import XMonad.Util.ClickableWorkspaces
import XMonad.Util.Loggers

-- | Xmobar status bar, setup so each screen spawns one
addStatusBar = dynamicSBs $ pure . xmobarN

-- TODO: Different logs?
xmobarN (S n) =
    statusBarPropTo xmonadDefProp ("xmobar -x " ++ show n) (myXPP myPP)

myXPP = clickablePP <=< dynamicIconsPP myIconConfig

myPP =
    def
        { ppOrder = \[ws, l, _, wins] -> [ws, l, wins]
        , ppSep = " • "
        , ppWsSep = " "
        , ppTitle = id
        , ppTitleSanitize = id
        , ppCurrent = white . xmobarBorder "Top" "#8be9fd" 3
        , ppVisible = white
        , ppVisibleNoWindows = Nothing
        , ppHidden = grey
        , ppHiddenNoWindows = const ""
        , ppUrgent = red . xmobarBorder "Top" "#8b090d" 3
        , ppExtras = [extraLogWindowTitle]
        }
  where
    white = xmobarColor "#f8f8f2" ""
    grey = xmobarColor "#a8a8a2" ""
    darkgrey = xmobarColor "#686862" ""
    red = xmobarColor "#ff5555" ""

extraLogWindowTitle = 
      xmobarColorL "lightblue" ""
    . wrapL "[" "]"
    . shortenL 25
    $ logTitle .| logConst ""

-- | Maps windows/apps to icons, to show in xmobar
-- NOTE: WM_CLASS=appName,className
-- TODO: Can I use unicode here?
myIcons :: Query [String]
myIcons =
    composeOne
        [ className =? "Spotify" -?> spotifyIcon
        , className =? "firefox" -?> firefoxIcon
        , className =? "steam" -?> steamIcon
        , className =? "TelegramDesktop" -?> telegramIcon
        , className =? "Alacritty" -?> terminalIcon
        , className =? "Thunar" -?> filesIcon
        , className =? "org.gnome.Weather" -?> weatherIcon
        , appName =? "Navigator" -?> internetIcon
        , appName =? "Mail" -?> mailIcon
        , fmap Just defaultIcon
        ]
  where
    firefoxIcon = appIcon' "\xf0239"
    spotifyIcon = appIcon' "\xf04d3"
    steamIcon = appIcon' "\xf0239"
    telegramIcon = appIcon' "\xf2c6"
    terminalIcon = appIcon' "\xf489"
    filesIcon = appIcon' "\xf413"
    weatherIcon = appIcon' "\xf067e"
    internetIcon = appIcon' "\xf059f"
    mailIcon = appIcon' "\xf01f0"
    windowIcon = appIcon' "\xeb7f"
    defaultIcon = windowIcon
    appIcon' s = appIcon $ cleanIcon s

-- | Format worspaces list as <number>:<icon> 
-- Uses <number>:<whitespace> 
myIconConfigFmt :: WorkspaceId -> [String] -> String
myIconConfigFmt wid [] = wid ++ ":" ++ emptyIcon
myIconConfigFmt wid wins = iconsFmtAppend concat wid wins

cleanIcon s = s ++ " "
emptyIcon = cleanIcon " "

myIconConfig =
    def { iconConfigIcons = myIcons
        , iconConfigFmt = myIconConfigFmt
        , iconConfigFilter = iconsGetFocus -- Show only the icon of the focused window
        }
