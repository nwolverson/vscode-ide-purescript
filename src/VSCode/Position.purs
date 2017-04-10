module VSCode.Position where

foreign import data Position :: Type

foreign import getLine :: Position -> Int
foreign import getCharacter :: Position -> Int
foreign import mkPosition :: Int -> Int -> Position
