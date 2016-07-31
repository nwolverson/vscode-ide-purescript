module VSCode.TextDocument where

import Prelude
import Control.Monad.Eff (Eff)
import VSCode.Range (Range)
import VSCode.Position (Position)

foreign import data TextDocument :: *

foreign import data EDITOR :: !

foreign import getPath :: forall eff. TextDocument -> Eff (editor :: EDITOR | eff) String

foreign import getText :: forall eff. TextDocument -> Eff (editor :: EDITOR | eff) String

foreign import getTextInRange :: forall eff. TextDocument -> Range -> Eff (editor :: EDITOR | eff) String

foreign import lineAtPosition :: forall eff. TextDocument -> Position -> Eff (editor :: EDITOR | eff) String

foreign import openTextDocument :: forall eff. String -> (TextDocument -> Eff (editor :: EDITOR | eff) Unit) ->  Eff (editor :: EDITOR | eff) Unit