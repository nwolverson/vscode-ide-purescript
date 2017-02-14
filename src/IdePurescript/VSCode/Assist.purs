module IdePurescript.VSCode.Assist (caseSplit, addClause) where

import Prelude
import PscIde as P
import Control.Monad.Aff (Aff)
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Class (liftEff)
import Control.Monad.Maybe.Trans (MaybeT(MaybeT), runMaybeT, lift)
import Data.Foldable (intercalate)
import Data.Maybe (Maybe(..))
import Data.Nullable (toNullable)
import Data.String (length)
import IdePurescript.PscIde (eitherToErr)
import IdePurescript.VSCode.Editor (identifierAtCursor)
import IdePurescript.VSCode.Types (MainEff, launchAffAndRaise)
import VSCode.Input (defaultInputOptions, getInput)
import VSCode.Position (Position, mkPosition, getLine)
import VSCode.Range (Range, mkRange)
import VSCode.TextDocument (lineAtPosition)
import VSCode.TextEditor (setTextInRange, getDocument)
import VSCode.Window (getSelectionRange, getCursorBufferPosition, getActiveTextEditor)

lineRange :: Position -> String -> Range
lineRange pos line =
  let col = getLine pos
      p = mkPosition col
  in
      mkRange (p 0) (p (length line))

caseSplit :: forall eff. Int -> Eff (MainEff eff) Unit
caseSplit port = do
  launchAffAndRaise $ runMaybeT body
  where
  body :: MaybeT (Aff (MainEff eff)) Unit
  body = do
    ed <- MaybeT $ liftEff getActiveTextEditor
    pos <- lift $ liftEff $ getCursorBufferPosition ed
    line <- lift $ liftEff $ lineAtPosition (getDocument ed) pos
    { range: { left, right } } <- MaybeT $ liftEff $ identifierAtCursor ed
    ty <- lift $ getInput (defaultInputOptions { prompt = toNullable $ Just "Parameter type" })
    lines <- lift $ eitherToErr $ P.caseSplit port line left right true ty
    lift $ void $ setTextInRange ed (intercalate "\n" lines) (lineRange pos line)

addClause :: forall eff. Int -> Eff (MainEff eff) Unit
addClause port = do
  editor <- getActiveTextEditor
  case editor of
    Just ed -> launchAffAndRaise $ do
      pos <- liftEff $ getCursorBufferPosition ed
      range <- liftEff $ getSelectionRange ed
      line <- liftEff $ lineAtPosition (getDocument ed) pos
      lines <- eitherToErr $ P.addClause port line true
      void $ setTextInRange ed (intercalate "\n" lines) (lineRange pos line)
    _ -> pure unit
