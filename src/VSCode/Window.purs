module VSCode.Window (getActiveTextEditor, TextEditor, EDITOR, getPath, getText, setText) where

import Prelude
import Control.Monad.Aff (makeAff, Aff)
import Control.Monad.Eff (Eff)
import Data.Maybe (Maybe(Just, Nothing))

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
