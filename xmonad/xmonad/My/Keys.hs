module My.Keys (myAdditionalKeys) where

import My.Scratchpads

import XMonad
import XMonad.StackSet
import XMonad.Actions.CycleWS
import XMonad.Actions.EasyMotion
import XMonad.Prompt.Shell
import XMonad.Hooks.ManageDocks
import XMonad.Util.NamedScratchpad

import Data.Map.Strict

-- | My keys. Some remap actual XMonad actions
-- Includes:
-- - Volume handlers
-- - EasyMotion for focus and killingjump there
-- - Shortcuts for handy scripts
-- - Replace dmenu with rofi
-- - Go to next/prev workspace
-- - Toggle scratchpads
myAdditionalKeys =
    [ ("<XF86AudioLowerVolume>", spawn "amixer sset Master 5%-")
    , ("<XF86AudioRaiseVolume>", spawn "amixer sset Master 5%+")
    , ("<XF86AudioMute>", spawn "amixer sset Master toggle")
    , ("M-f", selectWindow myEasyMotionConfig >>= (`whenJust` windows . focusWindow))
    , ("M-d", selectWindow myEasyMotionConfig >>= (`whenJust` killWindow))
    , ("M-/", spawn "get-active-xprops.sh")
    , ("M-p", spawn "rofi -show")
    , ("M-0", spawn "toggle-compositor.sh")
    , ("M-b", sendMessage ToggleStruts)
    , ("M-`", nextWS)
    , ("M-S-`", shiftToNext)
    , ("M-=", namedScratchpadAction myScratchpads "today")
    , ("M-'", shellPrompt def)
    ]

-- | Allows me select a window quickly
-- E.g. on activation, each window will have a letter shown so I can select
myEasyMotionConfig =
    def
        { sKeys =
            PerScreenKeys $
                fromList
                    [ (0, [xK_f, xK_d, xK_s, xK_a])
                    , (1, [xK_h, xK_j, xK_k, xK_l])
                    ]
        , cancelKey = xK_Escape
        }

