module LanguageServer.IdePurescript.Imports where

import Prelude
import PscIde.Command as C
import Control.Monad.Aff (Aff)
import Control.Monad.Eff.Class (liftEff)
import Control.Monad.Except (runExcept)
import Data.Either (Either(..), either)
import Data.Foreign (Foreign, readString, toForeign)
import Data.Maybe (Maybe(..))
import Data.Nullable (toNullable)
import IdePurescript.Modules (ImportResult(..), addExplicitImport)
import IdePurescript.PscIdeServer (ErrorLevel(..), Notify)
import IdePurescript.VSCode.Text (makeMinimalWorkspaceEdit)
import LanguageServer.DocumentStore (getDocument)
import LanguageServer.Handlers (applyEdit)
import LanguageServer.IdePurescript.Config (autocompleteAddImport)
import LanguageServer.IdePurescript.Types (MainEff, ServerState(..))
import LanguageServer.TextDocument (getText, getVersion)
import LanguageServer.Types (DocumentStore, DocumentUri(..), Settings)

addCompletionImport :: forall eff. Notify (MainEff eff) -> DocumentStore -> Settings -> ServerState (MainEff eff) -> Array Foreign -> Aff (MainEff eff) Foreign
addCompletionImport log docs config state args = do
  let shouldAddImport = autocompleteAddImport config
      ServerState { port, modules, conn } = state
  case port, (runExcept <<< readString) <$> args of
    Just port', [ Right identifier, mod', Right uri ] -> do
      let mod'' = either (const Nothing) Just mod'
      doc <- liftEff $ getDocument docs (DocumentUri uri)
      version <- liftEff $ getVersion doc
      text <- liftEff $ getText doc
      { state: modulesState', result } <- addExplicitImport modules port' uri text mod'' identifier
      liftEff $ case result of
        UpdatedImports newText -> do
          let edit = makeMinimalWorkspaceEdit (DocumentUri uri) version text newText
          case conn, edit of
            Just conn', Just edit' -> applyEdit conn' edit'
            _, _ -> pure unit
          pure successResult
        AmbiguousImport imps ->  do
          log Warning "Found ambiguous imports"
          pure $ toForeign $ (\(C.TypeInfo { module' }) -> module') <$> imps
        FailedImport -> log Error "Failed to import" $> successResult
    _, args' -> do
      liftEff $ log Info $ show args'
      pure successResult

    where
    successResult = toForeign $ toNullable Nothing


