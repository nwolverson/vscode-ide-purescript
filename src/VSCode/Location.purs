module VSCode.Location where

import VSCode.Position

foreign import data Location :: Type

foreign import mkLocation :: String -> Position -> Location 
