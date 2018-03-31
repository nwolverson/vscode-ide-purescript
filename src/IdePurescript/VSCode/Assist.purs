module IdePurescript.VSCode.Assist (caseSplit, addClause, getActivePosInfo, typedHole, fixTypo) where

import Prelude

import Control.Monad.Aff (Aff)
import Control.Monad.Aff.Class (liftAff)
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Class (liftEff)
import Control.Monad.Except (runExcept)
import Control.Monad.Maybe.Trans (MaybeT(..), runMaybeT)
import Data.Array (drop, findIndex, uncons, (!!))
import Data.Array as Array
import Data.Either (Either(..))
import Data.Foreign (Foreign, readArray, readString, toForeign, unsafeFromForeign)
import Data.Maybe (Maybe(..), maybe)
import Data.Nullable (toNullable)
import Data.String (length)
import Data.Traversable (traverse)
import IdePurescript.VSCode.Types (MainEff, launchAffAndRaise)
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

fixTypo :: forall eff. LanguageClient -> Array Foreign -> Eff (MainEff eff) Unit
fixTypo client args = launchAffAndRaise $ void $ go Nothing
  where
  go :: Maybe Foreign -> Aff (MainEff eff) Unit
  go choice =
    case args of 
      [ uriRaw, line, col ]
        | Right uri <- runExcept $ readString uriRaw -> void $ do
            res <- sendCommand client "purescript.fixTypo" (toNullable $ Just $ args <> Array.fromFoldable (toForeign <$> choice))
            case runExcept $ readArray res >>= traverse decodeTypoResult of
              Right arr | Array.length arr > 0 -> do
                let items = (map makeItem arr)
                pick <- showQuickPickItemsOpt items { placeHolder : toNullable $ Just $ "identifier" }
                case pick of
                  Just res -> go $ Just $ encodeTypoResult $ fromItem res
                  Nothing -> pure unit
              _ -> pure unit
      _ -> pure unit

  makeItem :: TypoResult -> QuickPickItem
  makeItem (TypoResult { identifier, mod }) = 
    { description: ""
    , detail: mod
    , label: identifier }

  fromItem :: QuickPickItem -> TypoResult
  fromItem ({ detail, label }) = TypoResult { identifier: label, mod: detail}
  
eqQuickPickItem :: QuickPickItem -> QuickPickItem -> Boolean
eqQuickPickItem {description, detail, label} {description: desc2, detail: detail2, label: label2} =
  description == desc2 && detail == detail2 && label == label2

typedHole :: forall eff. Array Foreign -> Eff (MainEff eff) Unit
typedHole args = launchAffAndRaise $ void $ do
  case uncons args of
    Just { head }
      | Just uri <- args !! 1
      , Just range <- args !! 2
      , tail <- drop 3 args -> 
    case runExcept $ readString head, readTypeInfo <$> tail of
      Right name, args -> void $ runMaybeT $ do
        let items = (map makeItem args)
        item :: QuickPickItem <- MaybeT $ showQuickPickItemsOpt items { placeHolder : toNullable $ Just $ "Filter hole suggestions for " <> name}
        index :: Int <- MaybeT $ pure $ findIndex (eqQuickPickItem item) items
        arg :: TypeInfo <- MaybeT $ pure $ args !! index
        liftAff $ executeAff ("purescript.typedHole-explicit") [ head, uri, range, toForeign arg ]
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
