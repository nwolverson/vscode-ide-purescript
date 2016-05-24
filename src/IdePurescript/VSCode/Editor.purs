module IdePurescript.VSCode.Editor where

import Prelude
import VSCode.Window (EDITOR, TextEditor, lineAtPosition, getCursorBufferPosition)
import VSCode.Position (getCharacter)
import Control.Monad.Eff (Eff)
import Data.Maybe (Maybe)
import IdePurescript.Tokens (WordRange, identifierAtPoint)

identifierAtCursor :: forall eff. TextEditor -> Eff (editor :: EDITOR | eff) (Maybe { word :: String, range :: WordRange, qualifier :: Maybe String })
identifierAtCursor editor = do
    pos <- getCursorBufferPosition editor
    line <- lineAtPosition editor pos
    pure $ identifierAtPoint line (getCharacter pos)
