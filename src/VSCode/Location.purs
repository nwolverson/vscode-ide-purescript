module VSCode.Location where

import VSCode.Position

foreign import data Location :: *

foreign import mkLocation :: String -> Position -> Location 
