module IdePurescript.VSCode.Editor where

import Prelude
import VSCode.Window (getCursorBufferPosition)
import VSCode.TextDocument (EDITOR, lineAtPosition)
import VSCode.TextEditor (TextEditor, getDocument)
import VSCode.Position (getCharacter)
import Control.Monad.Eff (Eff)
import Data.Maybe (Maybe)
import IdePurescript.Tokens (WordRange, identifierAtPoint)

type GetText eff = Int -> Int -> Int -> Int -> Eff eff String -- TODO eff


identifierAtCursor :: forall eff. TextEditor -> Eff (editor :: EDITOR | eff) (Maybe { word :: String, range :: WordRange, qualifier :: Maybe String })
identifierAtCursor editor = do
    let doc = getDocument editor
    pos <- getCursorBufferPosition editor
    line <- lineAtPosition doc pos
    pure $ identifierAtPoint line (getCharacter pos)

