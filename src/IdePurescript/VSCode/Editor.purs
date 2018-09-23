module IdePurescript.VSCode.Editor where

import Prelude

import Data.Maybe (Maybe)
import Effect (Effect)
import IdePurescript.Tokens (WordRange, identifierAtPoint)
import VSCode.Position (getCharacter)
import VSCode.TextDocument (lineAtPosition)
import VSCode.TextEditor (TextEditor, getDocument)
import VSCode.Window (getCursorBufferPosition)

type GetText = Int -> Int -> Int -> Int -> Effect String

identifierAtCursor :: TextEditor -> Effect (Maybe { word :: String, range :: WordRange, qualifier :: Maybe String })
identifierAtCursor editor = do
    let doc = getDocument editor
    pos <- getCursorBufferPosition editor
    line <- lineAtPosition doc pos
    pure $ identifierAtPoint line (getCharacter pos)

