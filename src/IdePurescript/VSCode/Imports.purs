module IdePurescript.VSCode.Imports where

import Prelude

import Control.Monad.Except (runExcept)
import Data.Either (Either(..))
import Data.Maybe (Maybe(..), maybe)
import Data.Nullable (toNullable)
import Data.Traversable (traverse)
import Effect (Effect)
import Effect.Aff (Aff)
import Effect.Class (liftEffect)
import Foreign (readArray, readString, unsafeToForeign)
import IdePurescript.VSCode.Assist (getActivePosInfo)
import IdePurescript.VSCode.Editor (identifierAtCursor)
import IdePurescript.VSCode.Types (launchAffAndRaise)
import LanguageServer.IdePurescript.Commands (addCompletionImport, addModuleImportCmd, cmdName, getAvailableModulesCmd)
import LanguageServer.Types (Command(..), DocumentUri)
import LanguageServer.Uri (filenameToUri)
import VSCode.Input (showQuickPick, defaultInputOptions, getInput)
import VSCode.LanguageClient (LanguageClient, sendCommand)
import VSCode.TextDocument (getPath)
import VSCode.TextEditor (getDocument)
import VSCode.Window (getActiveTextEditor)

addIdentImport :: LanguageClient -> Effect Unit
addIdentImport client = launchAffAndRaise $ void $ do 
  liftEffect getActivePosInfo >>= maybe (pure unit) \{ pos, uri, ed } -> do
    atCursor <- liftEffect $ identifierAtCursor ed
    let defaultIdent = maybe "" _.word atCursor
    ident <- getInput (defaultInputOptions { prompt = toNullable $ Just "Identifier", value = toNullable $ Just defaultIdent })
    addIdentImportMod ident uri Nothing
  where
    addIdentImportMod :: String -> DocumentUri -> Maybe String -> Aff Unit
    addIdentImportMod ident uri mod = do
      let Command { command, arguments } = addCompletionImport ident mod Nothing uri
      res <- sendCommand client command arguments
      case runExcept $ readArray res of
        Right forArr
          | Right arr <- runExcept $ traverse readString forArr
          -> showQuickPick arr >>= maybe (pure unit) (addIdentImportMod ident uri <<< Just)
        _ -> pure unit

addModuleImport :: LanguageClient -> Effect Unit
addModuleImport client = launchAffAndRaise $ void $ do
  modulesForeign <- sendCommand client (cmdName getAvailableModulesCmd) (toNullable Nothing)
  ed' <- liftEffect $ getActiveTextEditor
  case runExcept $ readArray modulesForeign, ed' of
    Right arr1, Just ed
      | Right modules <- runExcept $ traverse readString arr1
      -> do
        pick <- showQuickPick modules
        uri <- liftEffect $ filenameToUri =<< (getPath $ getDocument ed)
        atCursor <- liftEffect $ identifierAtCursor ed
        qual <- pure $ toNullable $ _.qualifier =<< atCursor
        case pick of
          Just modName -> void $ sendCommand client (cmdName addModuleImportCmd)
            (toNullable $ Just [ unsafeToForeign modName, unsafeToForeign qual, unsafeToForeign uri ])
          _ -> pure unit
    _, _ -> pure unit
