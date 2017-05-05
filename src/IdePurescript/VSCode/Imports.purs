module IdePurescript.VSCode.Imports where

import Prelude
import PscIde.Command as C
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Class (liftEff)
import Control.Monad.Eff.Console (log)
import Control.Monad.Eff.Ref (readRef, writeRef, Ref)
import Data.Maybe (Maybe(..), fromMaybe, maybe)
import Data.Nullable (toMaybe, toNullable)
import IdePurescript.Modules (State, ImportResult(..), addModuleImport, addExplicitImport)
import IdePurescript.PscIde (getAvailableModules)
import IdePurescript.VSCode.Assist (getActivePosInfo)
import IdePurescript.VSCode.Editor (identifierAtCursor)
import IdePurescript.VSCode.Types (MainEff, launchAffAndRaise, launchAffSilent)
import LanguageServer.IdePurescript.Commands (addCompletionImport)
import LanguageServer.Types (Command(..))
import VSCode.Command (executeAff)
import VSCode.Input (showQuickPick, defaultInputOptions, getInput)
import VSCode.TextDocument (getText, getPath)
import VSCode.TextEditor (setText, getDocument)
import VSCode.Window (getActiveTextEditor)

addIdentImport :: forall eff. Eff (MainEff eff) Unit
addIdentImport = launchAffAndRaise $ void $ do
  liftEff getActivePosInfo >>= maybe (pure unit) \{ pos, uri, ed } -> do
    atCursor <- liftEff $ identifierAtCursor ed
    let defaultIdent = maybe "" _.word atCursor
    ident <- getInput (defaultInputOptions { prompt = toNullable $ Just "Identifier", value = toNullable $ Just defaultIdent })      
    let Command { command, arguments } = addCompletionImport ident Nothing uri
    executeAff command (fromMaybe [] $ toMaybe arguments)

addIdentImportCmd :: forall eff. Ref State -> Int -> Eff (MainEff eff) Unit
addIdentImportCmd modulesState port = do
  ed <- getActiveTextEditor
  state <- readRef modulesState
  case ed of
    Just ed' -> launchAffSilent $ do
      atCursor <- liftEff $ identifierAtCursor ed'
      let defaultIdent = maybe "" _.word atCursor
      ident <- getInput (defaultInputOptions { prompt = toNullable $ Just "Identifier", value = toNullable $ Just defaultIdent })
      path <- liftEff $ getPath $ getDocument $ ed'
      text <- liftEff $ getText $ getDocument $ ed'
      addIdentImport state ed' path text Nothing ident
    Nothing -> pure unit
  where
    addIdentImport state editor path text moduleName ident = do
      { state: newState, result: output} <- addExplicitImport state port path text moduleName ident
      liftEff $ writeRef modulesState newState
      case output of
        FailedImport -> liftEff $ log $ "Failed to add import"
        UpdatedImports out -> do
          void $ setText editor out
        AmbiguousImport opts -> do
          mod <- showQuickPick ((\(C.TypeInfo { module' }) -> module') <$> opts)
          liftEff $ log $ show mod
          case mod of
            Just _ -> addIdentImport state editor path text mod ident
            _ -> pure unit

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
