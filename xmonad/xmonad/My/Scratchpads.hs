module My.Scratchpads (myScratchpads) where

import XMonad
import XMonad.Util.NamedScratchpad
import XMonad.StackSet

-- | List of the scratchpads I have configured
myScratchpads = [todayNotes]

todayNotes = NS "today" cmd query pos
    where
        cmd = "alacritty --class=Alacritty:Today -e nvim ~/today.txt"
        query = className =? "Alacritty:Today"
        pos = centerFloat

-- Not golden 
centerFloat = customFloating $ RationalRect (2 / 3) (0) (1 / 3) (1)

