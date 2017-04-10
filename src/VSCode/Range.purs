module VSCode.Range where

import VSCode.Position

foreign import data Range :: Type

foreign import getStart :: Range -> Position
foreign import getEnd :: Range -> Position
foreign import mkRange :: Position -> Position -> Range
