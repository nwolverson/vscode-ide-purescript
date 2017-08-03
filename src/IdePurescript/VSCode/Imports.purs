module IdePurescript.VSCode.Imports where

import Prelude
import Control.Monad.Aff (Aff)
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Class (liftEff)
import Control.Monad.Eff.Ref (Ref, readRef)
import Control.Monad.Except (runExcept)
import Data.Either (Either(..))
import Data.Foreign (readArray, readString)
import Data.Maybe (Maybe(..), maybe)
import Data.Nullable (toNullable)
import Data.Traversable (traverse)
import IdePurescript.Modules (State, addModuleImport)
import IdePurescript.PscIde (getAvailableModules)
import IdePurescript.VSCode.Assist (getActivePosInfo)
import IdePurescript.VSCode.Editor (identifierAtCursor)
import IdePurescript.VSCode.Types (MainEff, launchAffAndRaise, launchAffSilent)
import LanguageServer.IdePurescript.Commands (addCompletionImport)
import LanguageServer.Types (Command(..), DocumentUri)
import VSCode.Input (showQuickPick, defaultInputOptions, getInput)
import VSCode.LanguageClient (LanguageClient, sendCommand)
import VSCode.TextDocument (getText, getPath)
import VSCode.TextEditor (setText, getDocument)
import VSCode.Window (getActiveTextEditor)

addIdentImport :: forall eff. LanguageClient -> Eff (MainEff eff) Unit
addIdentImport client = launchAffAndRaise $ void $ do
  liftEff getActivePosInfo >>= maybe (pure unit) \{ pos, uri, ed } -> do
    atCursor <- liftEff $ identifierAtCursor ed
    let defaultIdent = maybe "" _.word atCursor
    ident <- getInput (defaultInputOptions { prompt = toNullable $ Just "Identifier", value = toNullable $ Just defaultIdent })
    addIdentImportMod ident uri Nothing
  where
    addIdentImportMod :: String -> DocumentUri -> Maybe String -> Aff (MainEff eff) Unit
    addIdentImportMod ident uri mod = do
      let Command { command, arguments } = addCompletionImport ident mod uri
      res <- sendCommand client command arguments
      case runExcept $ readArray res of
        Right forArr
          | Right arr <- runExcept $ traverse readString forArr
          -> showQuickPick arr >>= maybe (pure unit) (addIdentImportMod ident uri <<< Just)
        _ -> pure unit

-- TODO: How to implement via server
addModuleImportCmd :: forall eff. Ref State -> Int -> Eff (MainEff eff) Unit
addModuleImportCmd modulesState port =
  launchAffSilent $ do
    modules <- getAvailableModules port
    mod <- showQuickPick modules
    state <- liftEff $ readRef modulesState
    ed <- liftEff $ getActiveTextEditor
    case mod, ed of
      Just moduleName, Just ed' -> do
        path <- liftEff $ getPath $ getDocument $ ed'
        text <- liftEff $ getText $ getDocument $ ed'
        do
          output <- addModuleImport state port path text moduleName
          case output of
            Just { result } -> do
              void $ setText ed' result
            _ -> pure unit
      _, _ -> pure unit
