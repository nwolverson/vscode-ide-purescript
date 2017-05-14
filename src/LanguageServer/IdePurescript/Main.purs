module LanguageServer.IdePurescript.Main where

import Prelude
import Control.Monad.Aff (Aff, runAff)
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Class (liftEff)
import Control.Monad.Eff.Ref (modifyRef, newRef, readRef, writeRef)
import Control.Promise (Promise, fromAff)
import Data.Array (length)
import Data.Foldable (for_)
import Data.Foreign (Foreign, toForeign)
import Data.Maybe (Maybe(..), fromMaybe, maybe)
import Data.Newtype (over, un, unwrap)
import Data.Nullable (toMaybe, toNullable)
import Data.Profunctor.Strong (first)
import Data.StrMap (StrMap, empty, fromFoldable, insert, lookup, toUnfoldable)
import Data.Traversable (traverse)
import Data.Tuple (Tuple(..))
import IdePurescript.Modules (Module, getModulesForFile, initialModulesState)
import IdePurescript.PscErrors (PscError(..))
import IdePurescript.PscIdeServer (ErrorLevel(..), Notify)
import LanguageServer.Console (error, info, log, warn)
import LanguageServer.DocumentStore (getDocument, onDidSaveDocument)
import LanguageServer.Handlers (onCodeAction, onCompletion, onDefinition, onDidChangeConfiguration, onDocumentSymbol, onExecuteCommand, onHover, onWorkspaceSymbol, publishDiagnostics)
import LanguageServer.IdePurescript.Assist (addClause, caseSplit)
import LanguageServer.IdePurescript.Build (collectByFirst, fullBuild, getDiagnostics)
import LanguageServer.IdePurescript.CodeActions (getActions, onReplaceSuggestion)
import LanguageServer.IdePurescript.Commands (addClauseCmd, addCompletionImportCmd, buildCmd, caseSplitCmd, cmdName, commands, replaceSuggestionCmd, restartPscIdeCmd, startPscIdeCmd, stopPscIdeCmd)
import LanguageServer.IdePurescript.Completion (getCompletions)
import LanguageServer.IdePurescript.Imports (addCompletionImport)
import LanguageServer.IdePurescript.Server (retry, startServer')
import LanguageServer.IdePurescript.Symbols (getDefinition, getDocumentSymbols, getWorkspaceSymbols)
import LanguageServer.IdePurescript.Tooltips (getTooltips)
import LanguageServer.IdePurescript.Types (ServerState(..), MainEff, CommandHandler)
import LanguageServer.Setup (InitParams(..), initConnection, initDocumentStore)
import LanguageServer.TextDocument (getText, getUri)
import LanguageServer.Types (Diagnostic, DocumentUri(..), Settings, TextDocumentIdentifier(..))
import LanguageServer.Uri (filenameToUri, uriToFilename)
import PscIde (load)

defaultServerState :: forall eff. ServerState eff
defaultServerState = ServerState
  { port: Nothing
  , deactivate: pure unit
  , root: Nothing
  , conn: Nothing
  , modules: initialModulesState
  , modulesFile: Nothing
  , diagnostics: empty
  }

main :: forall eff. Eff (MainEff eff) Unit
main = do
  state <- newRef defaultServerState
  config <- newRef (toForeign {})

  let logError :: Notify (MainEff eff)
      logError l s = do
        (_.conn <$> unwrap <$> readRef state) >>=
          maybe (pure unit) (\conn -> case l of 
            Success -> log conn s
            Info -> info conn s
            Warning -> warn conn s
            Error -> error conn s)
  let launchAffLog = void <<< runAff (logError Error <<< show) (const $ pure unit)

  let stopPscIdeServer :: Aff (MainEff eff) Unit
      stopPscIdeServer = liftEff do
        join $ _.deactivate <$> unwrap <$> readRef state
        modifyRef state (over ServerState $ _ { port = Nothing, deactivate = pure unit })
        liftEff $ logError Success "Stopped psc-ide server"

      startPscIdeServer = do
        rootPath <- liftEff $ (_.root <<< unwrap) <$> readRef state
        settings <- liftEff $ readRef config
        startRes <- startServer' settings rootPath logError logError
        retry logError 6 case startRes of
          { port: Just port, quit } -> do
            _ <- load port [] []
            liftEff $ modifyRef state (over ServerState $ _ { port = Just port, deactivate = quit })
            liftEff $ logError Success "Started psc-ide server"
          _ -> pure unit

      restartPscIdeServer = do
        stopPscIdeServer
        startPscIdeServer

  conn <- initConnection commands $ \({ params: InitParams { rootPath }, conn }) ->  do
    modifyRef state (over ServerState $ _ { root = toMaybe rootPath })
    launchAffLog startPscIdeServer
  modifyRef state (over ServerState $ _ { conn = Just conn })

  onDidChangeConfiguration conn $ writeRef config <<< _.settings

  log conn "PureScript Language Server started"

  documents <- initDocumentStore conn

  let showModule :: Module -> String
      showModule = unwrap >>> case _ of
         { moduleName, importType, qualifier } -> moduleName <> maybe "" (" as " <> _) qualifier

  let updateModules :: DocumentUri -> Aff (MainEff eff) Unit
      updateModules uri = 
        liftEff (readRef state) >>= case _ of 
          ServerState { port: Just port, modulesFile } 
            | modulesFile /= Just uri -> do
            text <- liftEff $ getDocument documents uri >>= getText
            path <- liftEff $ uriToFilename uri
            -- TODO use temp file
            modules <- getModulesForFile port path text
            liftEff $ modifyRef state $ over ServerState (_ { modules = modules, modulesFile = Just uri })
            -- liftEff $ info conn $ "Updated modules to: " <> show modules.main <> " / " <> show (showModule <$> modules.modules)
          _ -> pure unit

  let runHandler :: forall a b . String -> (b -> Maybe DocumentUri) -> (Settings -> ServerState (MainEff eff) -> b -> Aff (MainEff eff) a) -> b -> Eff (MainEff eff) (Promise a)
      runHandler handlerName docUri f b =
        fromAff do
          c <- liftEff $ readRef config
          s <- liftEff $ readRef state
          -- liftEff $ maybe (pure unit) (\con -> log con $ "handler " <> handlerName) (_.conn $ unwrap s)
          maybe (pure unit) updateModules (docUri b)          
          f c s b

  let getTextDocUri :: forall r. { textDocument :: TextDocumentIdentifier | r } -> Maybe DocumentUri
      getTextDocUri = (Just <<< _.uri <<< un TextDocumentIdentifier <<< _.textDocument)

  onCompletion conn $ runHandler "onCompletion" getTextDocUri (getCompletions documents)
  onDefinition conn $ runHandler "onDefinition" getTextDocUri (getDefinition documents)
  onDocumentSymbol conn $ runHandler "onDocumentSymbol" getTextDocUri getDocumentSymbols
  onWorkspaceSymbol conn $ runHandler "onWorkspaceSymbol" (const Nothing) getWorkspaceSymbols
  onHover conn $ runHandler "onHover" getTextDocUri (getTooltips documents)
  onCodeAction conn $ runHandler "onCodeAction" getTextDocUri (getActions documents)

  onDidSaveDocument documents \{ document } -> launchAffLog do
    let uri = getUri document
    c <- liftEff $ readRef config
    s <- liftEff $ readRef state
    { pscErrors, diagnostics } <- getDiagnostics uri c s
    filename <- liftEff $ uriToFilename uri
    let fileDiagnostics = fromMaybe [] $ lookup filename diagnostics
    liftEff $ writeRef state $ over ServerState (\s1 -> s1 { 
      diagnostics = insert (un DocumentUri uri) pscErrors (s1.diagnostics)
    , modulesFile = Nothing -- Force reload of modules on next request
    }) s
    liftEff $ publishDiagnostics conn { uri, diagnostics: fileDiagnostics }

  let onBuild docs c s arguments = do
        { pscErrors, diagnostics } <- fullBuild docs c s arguments
        liftEff $ log conn $ "Built with " <> (show $ length pscErrors) <> " issues"
        pscErrorsMap <- liftEff $ collectByFirst <$> traverse (\(e@PscError { filename }) -> do
          uri <- maybe (pure Nothing) (\f -> Just <$> un DocumentUri <$> filenameToUri f) filename
          pure $ Tuple uri e)
            pscErrors
        liftEff $ writeRef state $ over ServerState (_ { diagnostics = pscErrorsMap }) s
        liftEff $ for_ (toUnfoldable diagnostics :: Array (Tuple String (Array Diagnostic))) \(Tuple filename fileDiagnostics) -> do
          uri <- filenameToUri filename
          publishDiagnostics conn { uri, diagnostics: fileDiagnostics }

  let noResult = toForeign $ toNullable Nothing
  let voidHandler :: forall a. CommandHandler eff a -> CommandHandler eff Foreign
      voidHandler h d c s a = h d c s a $> noResult
      simpleHandler h d c s a = h $> noResult
  let handlers :: StrMap (CommandHandler eff Foreign)
      handlers = fromFoldable $ first cmdName <$>
      [ Tuple caseSplitCmd $ voidHandler caseSplit
      , Tuple addClauseCmd $ voidHandler addClause
      , Tuple replaceSuggestionCmd $ voidHandler onReplaceSuggestion
      , Tuple buildCmd $ voidHandler onBuild
      , Tuple addCompletionImportCmd $ addCompletionImport logError
      , Tuple startPscIdeCmd $ simpleHandler startPscIdeServer
      , Tuple stopPscIdeCmd $ simpleHandler stopPscIdeServer
      , Tuple restartPscIdeCmd $ simpleHandler restartPscIdeServer
      ]

  onExecuteCommand conn $ \{ command, arguments } -> fromAff do
    c <- liftEff $ readRef config
    s <- liftEff $ readRef state
    case lookup command handlers of 
      Just handler -> handler documents c s arguments
      Nothing -> do
        liftEff $ error conn $ "Unknown command: " <> command
        pure noResult
