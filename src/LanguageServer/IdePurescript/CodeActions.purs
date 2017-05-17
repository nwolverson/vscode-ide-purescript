module LanguageServer.IdePurescript.CodeActions where

import Prelude
import Control.Monad.Aff (Aff)
import Control.Monad.Eff.Class (liftEff)
import Control.Monad.Except (runExcept)
import Data.Array (concat, singleton)
import Data.Either (Either(..))
import Data.Foreign (F, Foreign, readInt, readString)
import Data.Foreign.Index ((!))
import Data.Maybe (Maybe(..), fromMaybe)
import Data.Newtype (un)
import Data.StrMap (lookup)
import Data.String (length, trim)
import Data.String.Regex (regex)
import Data.String.Regex.Flags (noFlags)
import Data.Traversable (traverse)
import IdePurescript.PscErrors (PscError(..))
import IdePurescript.QuickFix (getTitle)
import IdePurescript.Regex (test')
import LanguageServer.DocumentStore (getDocument)
import LanguageServer.Handlers (CodeActionParams, applyEdit)
import LanguageServer.IdePurescript.Build (positionToRange)
import LanguageServer.IdePurescript.Commands (replaceSuggestion)
import LanguageServer.IdePurescript.Types (ServerState(..), MainEff)
import LanguageServer.TextDocument (getText, getTextAtRange, getVersion)
import LanguageServer.Types (Command, DocumentStore, DocumentUri(..), Position(..), Range(..), Settings, TextDocumentEdit(..), TextDocumentIdentifier(..), TextEdit(..), workspaceEdit)

getActions :: forall eff. DocumentStore -> Settings -> ServerState (MainEff eff) -> CodeActionParams -> Aff (MainEff eff) (Array Command)
getActions documents settings (ServerState { diagnostics, conn }) { textDocument, range } =  
  case lookup (un DocumentUri $ _.uri $ un TextDocumentIdentifier textDocument) diagnostics of
    Just errs -> concat <$> traverse asCommand errs
    _ -> pure []
  where
    asCommand (PscError { position: Just position, suggestion: Just { replacement, replaceRange }, errorCode })
      | contains range (positionToRange position) = do
      let range' = positionToRange $ fromMaybe position replaceRange
      pure $ [ replaceSuggestion (getTitle errorCode) (_.uri $ un TextDocumentIdentifier textDocument) replacement range' ]
    asCommand _ = pure []

    -- TODO if isUnknownToken errorCode -> then add quick fix action

    contains (Range { start, end }) (Range { start: start', end: end' }) = start <= start' && end >= end'

readRange :: Foreign -> F Range
readRange r = do
  start <- r ! "start" >>= readPosition
  end <- r ! "end" >>= readPosition
  pure $ Range { start, end }
  where
  readPosition p = do
    line <- p ! "line" >>= readInt
    character <- p ! "character" >>= readInt
    pure $ Position { line, character }

afterEnd :: Range -> Range
afterEnd (Range { end: end@(Position { line, character }) }) = 
  Range
    { start: end
    , end: Position { line, character: character + 10 }
    }

onReplaceSuggestion :: forall eff. DocumentStore -> Settings -> ServerState (MainEff eff) -> Array Foreign -> Aff (MainEff eff) Unit
onReplaceSuggestion docs config (ServerState { conn }) args =
  case conn, args of 
    Just conn', [ uri', replacement', range' ]
      | Right uri <- runExcept $ readString uri'
      , Right replacement <- runExcept $ readString replacement'
      , Right range <- runExcept $ readRange range'
      -> liftEff do
        doc <- getDocument docs (DocumentUri uri)
        text <- getText doc
        version <- getVersion doc

        origText <- getTextAtRange doc range
        afterText <- getTextAtRange doc (afterEnd range)

        let trailingNewline = test' (regex """\n\s+$""" noFlags) replacement
        let addNewline = trailingNewline && length (trim afterText) > 0
        let newText = trim replacement <> if addNewline then "\n" else ""
        let textEdit = TextEdit { range, newText }
        let docid = TextDocumentIdentifier { uri: DocumentUri uri, version }
        let edit = workspaceEdit $ singleton $ TextDocumentEdit { textDocument: docid, edits: [ textEdit ] }

        -- TODO: Check original & expected text ?
        applyEdit conn' edit
    _, _ -> pure unit
