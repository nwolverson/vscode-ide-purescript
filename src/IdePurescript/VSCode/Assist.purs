module IdePurescript.VSCode.Assist (caseSplit, addClause, getActivePosInfo) where

import Prelude
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Class (liftEff)
import Data.Foreign (toForeign)
import Data.Maybe (Maybe(..), maybe)
import Data.Nullable (toNullable)
import Data.String (length)
import IdePurescript.VSCode.Types (MainEff, launchAffAndRaise)
import LanguageServer.IdePurescript.Commands (cmdName, caseSplitCmd, addClauseCmd)
import LanguageServer.Types (DocumentUri)
import LanguageServer.Uri (filenameToUri)
import VSCode.Command (executeAff)
import VSCode.Input (defaultInputOptions, getInput)
import VSCode.Position (Position, getCharacter, getLine, mkPosition)
import VSCode.Range (Range, mkRange)
import VSCode.TextDocument (getPath)
import VSCode.TextEditor (TextEditor, getDocument)
import VSCode.Window (getActiveTextEditor, getCursorBufferPosition)

lineRange :: Position -> String -> Range
lineRange pos line = mkRange (p 0) (p (length line))
  where
  col = getLine pos
  p = mkPosition col

getActivePosInfo :: forall eff. Eff (MainEff eff) (Maybe { pos :: Position, uri :: DocumentUri, ed :: TextEditor })
getActivePosInfo = 
  getActiveTextEditor >>= maybe (pure Nothing) \ed -> do
    pos <- getCursorBufferPosition ed
    path <- getPath $ getDocument ed
    uri <- filenameToUri path
    pure $ Just { pos, uri, ed }

caseSplit :: forall eff. Eff (MainEff eff) Unit
caseSplit = launchAffAndRaise $ void $ do
  liftEff getActivePosInfo >>= maybe (pure unit) \{ pos, uri } -> do
      ty <- getInput (defaultInputOptions { prompt = toNullable $ Just "Parameter type" })
      executeAff (cmdName caseSplitCmd) [ toForeign uri, toForeign $ getLine pos, toForeign $ getCharacter pos, toForeign ty ]

addClause :: forall eff. Eff (MainEff eff) Unit
addClause = launchAffAndRaise $ void $ do
  liftEff getActivePosInfo >>= maybe (pure unit) \{ pos, uri } ->
    executeAff (cmdName addClauseCmd) [ toForeign uri, toForeign $ getLine pos, toForeign $ getCharacter pos ]
  
