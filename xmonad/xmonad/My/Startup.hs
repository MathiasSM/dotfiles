module My.Startup (myStartupHook) where

import XMonad

import XMonad.Prelude
import XMonad.Util.Cursor (setDefaultCursor)
import XMonad.Util.EZConfig

import Control.Arrow
import Data.List.NonEmpty qualified as NE
import Data.Map qualified as M
import Data.Map.Strict qualified as StrictMap
import Data.Ord
import Debug.Trace (traceShow)


-- | XMonad startup hook
-- Includes:
-- - Set default cursor to usual pointer
-- - Check duplicates and bad keybindings (TODO: Fix)
myStartupHook config keys = do
    setDefaultCursor xC_left_ptr
    trace $ show $ dups config keys

dups config =
    map (snd . NE.head)
        . traceWith show
        . mapMaybe NE.nonEmpty
        . traceWith show
        . groupBy ((==) `on` fst)
        . traceWith show
        . sortBy (comparing fst)
        . traceWith show
        . map (first fromJust)
        . traceWith show
        . filter (isJust . fst)
        . ks config

ks config =
    map ((readKeySequence config &&& id) . fst)

traceWith f a = traceShow (f a) a
