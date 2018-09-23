module VSCode.TextDocument where

import Prelude

import Effect (Effect)
import VSCode.Position (Position)
import VSCode.Range (Range)

foreign import data TextDocument :: Type

foreign import getPath :: TextDocument -> Effect String

foreign import getText :: TextDocument -> Effect String

foreign import getTextInRange :: TextDocument -> Range -> Effect String

foreign import lineAtPosition :: TextDocument -> Position -> Effect String

foreign import openTextDocument :: String -> (TextDocument -> Effect Unit) ->  Effect Unit