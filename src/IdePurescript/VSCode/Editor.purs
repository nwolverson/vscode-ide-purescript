module IdePurescript.VSCode.Editor where

import Prelude
import VSCode.Window
import VSCode.Range
import VSCode.Position
import Control.Monad.Eff
import Data.Maybe
import IdePurescript.Tokens

-- getLinePosition :: forall eff. TextEditor -> Eff (editor :: EDITOR | eff) { line :: String, col :: Int, pos :: Position, range :: Range }
-- getLinePosition ed = do
--   pos <- getCursorBufferPosition ed
--   line <- lineAtPosition ed pos
--   pure { line, pos, col, range }

identifierAtCursor :: forall eff. TextEditor -> Eff (editor :: EDITOR | eff) (Maybe { word :: String, range :: WordRange, qualifier :: Maybe String })
identifierAtCursor editor = do
    pos <- getCursorBufferPosition editor
    line <- lineAtPosition editor pos
    pure $ identifierAtPoint line (getCharacter pos)
    

-- foreign import getCursorBufferPosition :: forall eff. TextEditor -> Eff (editor :: EDITOR | eff) Position

-- foreign import getSelectionRange :: forall eff. TextEditor -> Eff (editor :: EDITOR | eff) Range

-- foreign import getTextInRange :: forall eff. TextEditor -> Range -> Eff (editor :: EDITOR | eff) String

-- foreign import lineAtPosition :: forall eff. TextEditor -> Position -> Eff (editor :: EDITOR | eff) String