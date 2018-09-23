module VSCode.Window (getActiveTextEditor, getCursorBufferPosition, getSelectionRange, setStatusBarMessage) where

import Prelude

import Data.Maybe (Maybe(Just, Nothing))
import Effect (Effect)
import VSCode.Position (Position)
import VSCode.Range (Range)
import VSCode.TextEditor (TextEditor)

foreign import getActiveTextEditorImpl :: Maybe TextEditor -> (TextEditor -> Maybe TextEditor) -> Effect (Maybe TextEditor)

getActiveTextEditor :: Effect (Maybe TextEditor)
getActiveTextEditor = getActiveTextEditorImpl Nothing Just

foreign import getCursorBufferPosition :: TextEditor -> Effect Position

foreign import getSelectionRange :: TextEditor -> Effect Range

foreign import setStatusBarMessage :: String -> Effect Unit