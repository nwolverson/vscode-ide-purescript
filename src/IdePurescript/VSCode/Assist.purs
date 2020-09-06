module IdePurescript.VSCode.Assist (caseSplit, addClause, getActivePosInfo, typedHole) where

import Prelude

import Control.Monad.Except (runExcept)
import Control.Monad.Maybe.Trans (MaybeT(..), runMaybeT)
import Data.Array (drop, findIndex, uncons, (!!))
import Data.Array as Array
import Data.Either (Either(..))
import Data.Maybe (Maybe(..), maybe)
import Data.Nullable (toNullable)
import Data.String (length)
import Data.Traversable (traverse)
import Effect (Effect)
import Effect.Aff (Aff)
import Effect.Aff.Class (liftAff)
import Effect.Class (liftEffect)
import Foreign (Foreign, readArray, readString, unsafeFromForeign, unsafeToForeign)
import IdePurescript.VSCode.Types (launchAffAndRaise)
import LanguageServer.IdePurescript.Assist (TypoResult(..), decodeTypoResult, encodeTypoResult)
import LanguageServer.IdePurescript.Commands (cmdName, caseSplitCmd, addClauseCmd)
import LanguageServer.Types (DocumentUri)
import LanguageServer.Uri (filenameToUri)
import PscIde.Command (TypeInfo(..))
import VSCode.Command (executeAff)
import VSCode.Input (QuickPickItem, defaultInputOptions, getInput, showQuickPickItemsOpt)
import VSCode.LanguageClient (LanguageClient, sendCommand)
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

getActivePosInfo :: Effect (Maybe { pos :: Position, uri :: DocumentUri, ed :: TextEditor })
getActivePosInfo = 
  getActiveTextEditor >>= maybe (pure Nothing) \ed -> do
    pos <- getCursorBufferPosition ed
    path <- getPath $ getDocument ed
    uri <- filenameToUri path
    pure $ Just { pos, uri, ed }

caseSplit :: Effect Unit
caseSplit = launchAffAndRaise $ void $ do
  liftEffect getActivePosInfo >>= maybe (pure unit) \{ pos, uri } -> do
      ty <- getInput (defaultInputOptions { prompt = toNullable $ Just "Parameter type" })
      executeAff (cmdName caseSplitCmd) [ unsafeToForeign uri, unsafeToForeign $ getLine pos, unsafeToForeign $ getCharacter pos, unsafeToForeign ty ]

addClause :: Effect Unit
addClause = launchAffAndRaise $ void $ do
  liftEffect getActivePosInfo >>= maybe (pure unit) \{ pos, uri } ->
    executeAff (cmdName addClauseCmd) [ unsafeToForeign uri, unsafeToForeign $ getLine pos, unsafeToForeign $ getCharacter pos ]

eqQuickPickItem :: QuickPickItem -> QuickPickItem -> Boolean
eqQuickPickItem {description, detail, label} {description: desc2, detail: detail2, label: label2} =
  description == desc2 && detail == detail2 && label == label2

typedHole :: Array Foreign -> Effect Unit
typedHole args = launchAffAndRaise $ void $ do
  case uncons args of
    Just { head }
      | Just uri <- args !! 1
      , Just range <- args !! 2
      , tail <- drop 3 args -> 
      case runExcept $ readString head, readTypeInfo <$> tail of
        Right name, args' -> void $ runMaybeT $ do
          let items = (map makeItem args')
          item :: QuickPickItem <- MaybeT $ showQuickPickItemsOpt items { placeHolder : toNullable $ Just $ "Filter hole suggestions for " <> name}
          index :: Int <- MaybeT $ pure $ findIndex (eqQuickPickItem item) items
          arg :: TypeInfo <- MaybeT $ pure $ args' !! index
          liftAff $ executeAff ("purescript.typedHole-explicit") [ head, uri, range, unsafeToForeign arg ]
        _, _ -> pure unit
    _ -> pure unit
  where
  readTypeInfo :: Foreign -> TypeInfo
  readTypeInfo obj = unsafeFromForeign obj

  makeItem :: TypeInfo -> QuickPickItem
  makeItem (TypeInfo {identifier, type',  module'}) = 
    { description:  module'
    , detail: type'
    , label: identifier }
