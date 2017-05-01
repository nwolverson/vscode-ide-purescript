module LanguageServer.IdePurescript.Imports where

import Prelude
import Control.Monad.Aff (Aff)
import Control.Monad.Eff.Class (liftEff)
import Control.Monad.Except (runExcept)
import Data.Array (singleton)
import Data.Either (Either(..))
import Data.Foreign (Foreign, readString)
import Data.Maybe (Maybe(..), maybe)
import Data.String (length)
import IdePurescript.Modules (ImportResult(..), addExplicitImport)
import IdePurescript.PscIdeServer (ErrorLevel(..), Notify)
import LanguageServer.DocumentStore (getDocument)
import LanguageServer.Handlers (applyEdit)
import LanguageServer.IdePurescript.Config (autocompleteAddImport)
import LanguageServer.IdePurescript.Types (MainEff, ServerState(..))
import LanguageServer.TextDocument (getText, getVersion, positionAtOffset)
import LanguageServer.Types (DocumentStore, DocumentUri(..), Position(..), Range(..), Settings, TextDocumentEdit(..), TextDocumentIdentifier(..), TextEdit(..), workspaceEdit)

addCompletionImport :: forall eff. DocumentStore -> Notify (MainEff eff)  -> Settings -> ServerState (MainEff eff) -> Array Foreign -> Aff (MainEff eff) Unit
addCompletionImport docs log config state args = do
  let shouldAddImport = autocompleteAddImport config
      ServerState { port, modules, conn } = state
  case port, (runExcept <<< readString) <$> args of
    Just port', [ Right identifier, Right mod, Right uri ] -> do   
      doc <- liftEff $ getDocument docs (DocumentUri uri)
      version <- liftEff $ getVersion doc
      text <- liftEff $ getText doc
      { state: modulesState', result } <- addExplicitImport modules port' uri text (Just mod) identifier
      liftEff $ case result of
        UpdatedImports newText -> do
          textEdit <- TextEdit <$> { range: _, newText } <$> allTextRange doc text
          let docid = TextDocumentIdentifier { uri: DocumentUri uri, version }
          let edit = workspaceEdit $ singleton $ TextDocumentEdit { textDocument: docid, edits: [ textEdit ] }
          maybe (pure unit) (flip applyEdit edit) conn
        AmbiguousImport _ -> log Warning "Found ambiguous imports"
        FailedImport -> log Error "Failed to import"
      pure unit
    _, _ -> pure unit

    where
    allTextRange doc text = do
      end <- positionAtOffset doc (length text)
      pure $ Range { start: Position { line: 0, character: 0 }, end }

-- addCompletionImport logCb stateRef port args = case args of
--   [ line, char, item ] -> case runExcept $ readInt line, runExcept $ readInt char of
--     Right line', Right char' -> do
--       let item' = (unsafeCoerce item) :: Command.TypeInfo
--       Command.TypeInfo { identifier, module' } <- pure item'
--       ed <- liftEff $ getActiveTextEditor
--       case ed of
--         Just ed' -> do
--           let doc = getDocument ed'
--           text <- liftEff $ getText doc
--           path <- liftEff $ getPath doc
--           state <- liftEff $ readRef stateRef
--           { state: newState, result: output} <- addExplicitImport state port path text (Just module') identifier
--           liftEff $ writeRef stateRef newState
--           case output of
--             UpdatedImports out -> void $ setTextViaDiff ed' out
--             AmbiguousImport opts -> liftEff $ logCb Warning "Found ambiguous imports"
--             FailedImport -> liftEff $ logCb Error "Failed to import"
--           pure unit
--         Nothing -> pure unit
--       pure unit
--     _, _ -> liftEff $ logCb Error "Wrong argument type"
--   _ -> liftEff $ logCb Error "Wrong command arguments"

