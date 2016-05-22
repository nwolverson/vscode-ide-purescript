module VSCode.Window (getActiveTextEditor, TextEditor, EDITOR, getPath, getText, setText, setTextInRange, getCursorBufferPosition, getSelectionRange, getTextInRange, lineAtPosition) where

import Prelude
import Control.Monad.Aff (makeAff, Aff)
import Control.Monad.Eff (Eff)
import Data.Maybe (Maybe(Just, Nothing))
import VSCode.Range
import VSCode.Position

foreign import getActiveTextEditorImpl :: forall eff. Maybe TextEditor -> (TextEditor -> Maybe TextEditor) -> Eff eff (Maybe TextEditor)

getActiveTextEditor :: forall eff. Eff eff (Maybe TextEditor)
getActiveTextEditor = getActiveTextEditorImpl Nothing Just

foreign import data TextEditor :: *

foreign import data EDITOR :: !

foreign import getPath :: forall eff. TextEditor -> Eff (editor :: EDITOR | eff) String

foreign import getText :: forall eff. TextEditor -> Eff (editor :: EDITOR | eff) String

foreign import setTextImpl :: forall eff. TextEditor -> String -> (Boolean -> Eff (editor :: EDITOR | eff) Unit) -> Eff (editor :: EDITOR | eff) Unit

setText :: forall eff. TextEditor -> String -> Aff (editor :: EDITOR | eff) Boolean
setText ed s = makeAff $ \_ succ -> setTextImpl ed s succ

foreign import setTextInRangeImpl :: forall eff. TextEditor -> String -> Range -> (Boolean -> Eff (editor :: EDITOR | eff) Unit) -> Eff (editor :: EDITOR | eff) Unit

setTextInRange :: forall eff. TextEditor -> String -> Range -> Aff (editor :: EDITOR | eff) Boolean
setTextInRange ed s range = makeAff $ \_ succ -> setTextInRangeImpl ed s range succ

foreign import getCursorBufferPosition :: forall eff. TextEditor -> Eff (editor :: EDITOR | eff) Position

foreign import getSelectionRange :: forall eff. TextEditor -> Eff (editor :: EDITOR | eff) Range

foreign import getTextInRange :: forall eff. TextEditor -> Range -> Eff (editor :: EDITOR | eff) String

foreign import lineAtPosition :: forall eff. TextEditor -> Position -> Eff (editor :: EDITOR | eff) String