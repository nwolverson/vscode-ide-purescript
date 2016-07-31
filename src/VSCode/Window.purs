module VSCode.Window (getActiveTextEditor, getCursorBufferPosition, getSelectionRange) where

import Prelude
import Control.Monad.Eff (Eff)
import Data.Maybe (Maybe(Just, Nothing))
import VSCode.Range (Range)
import VSCode.Position (Position)
import VSCode.TextDocument (EDITOR)
import VSCode.TextEditor (TextEditor)

foreign import getActiveTextEditorImpl :: forall eff. Maybe TextEditor -> (TextEditor -> Maybe TextEditor) -> Eff eff (Maybe TextEditor)

getActiveTextEditor :: forall eff. Eff eff (Maybe TextEditor)
getActiveTextEditor = getActiveTextEditorImpl Nothing Just

foreign import getCursorBufferPosition :: forall eff. TextEditor -> Eff (editor :: EDITOR | eff) Position

foreign import getSelectionRange :: forall eff. TextEditor -> Eff (editor :: EDITOR | eff) Range

