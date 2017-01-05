module IdePurescript.VSCode.Main where

import Prelude
import IdePurescript.Completion as C
import PscIde.Command as Command
import VSCode.Notifications as Notify
import Control.Monad.Aff (later', attempt, Aff, runAff)
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Class (liftEff)
import Control.Monad.Eff.Console (log)
import Control.Monad.Eff.Ref (REF, Ref, readRef, newRef, writeRef)
import Control.Monad.Except (runExcept)
import Control.Promise (Promise, fromAff)
import Data.Array (uncons)
import Data.Either (Either(..), either)
import Data.Foreign (readInt, readString, readBoolean, Foreign)
import Data.Function.Eff (EffFn4, EffFn3, EffFn2, EffFn1, runEffFn4, mkEffFn3, mkEffFn2, mkEffFn1)
import Data.Maybe (Maybe(Just, Nothing), fromMaybe)
import Data.Nullable (toNullable, Nullable)
import Data.String (trim, null)
import Data.String.Regex (Regex, regex, split)
import Data.String.Regex.Flags (noFlags)
import IdePurescript.Build (Command(Command), build, rebuild)
import IdePurescript.Completion (SuggestionResult(..), SuggestionType(..))
import IdePurescript.Modules (ImportResult(FailedImport, AmbiguousImport, UpdatedImports), addExplicitImport, State, initialModulesState, getQualModule, getUnqualActiveModules, getModulesForFile, getMainModule)
import IdePurescript.PscErrors (PscError(PscError))
import IdePurescript.PscIde (getType, getCompletion, getLoadedModules, loadDeps)
import IdePurescript.PscIdeServer (Notify, ErrorLevel(Error, Warning, Info, Success))
import IdePurescript.PscIdeServer (startServer', QuitCallback, ServerEff) as P
import IdePurescript.Regex (match')
import IdePurescript.VSCode.Assist (addClause, caseSplit)
import IdePurescript.VSCode.Editor (GetText)
import IdePurescript.VSCode.Imports (addModuleImportCmd, addIdentImportCmd)
import IdePurescript.VSCode.Symbols (SymbolInfo, SymbolQuery(..), getDefinition, getSymbols)
import IdePurescript.VSCode.Types (MainEff, liftEffM)
import PscIde (load) as P
import PscIde (NET, suggestTypos)
import PscIde.Command (TypeInfo(..))
import Unsafe.Coerce (unsafeCoerce)
import VSCode.Command (register)
import VSCode.Diagnostic (Diagnostic, mkDiagnostic)
import VSCode.Location (Location)
import VSCode.Position (mkPosition)
import VSCode.Range (mkRange, Range)
import VSCode.TextDocument (TextDocument, getPath, getText)
import VSCode.TextEditor (setTextViaDiff, getDocument)
import VSCode.Window (getActiveTextEditor, setStatusBarMessage, WINDOW)
import VSCode.Workspace (rootPath, getValue, getConfiguration, WORKSPACE)

ignoreError :: forall a eff. a -> Eff eff Unit
ignoreError _ = pure unit

useEditor :: forall eff. Int -> (Ref State) -> String -> String -> Eff (net :: NET, ref :: REF | eff) Unit
useEditor port modulesStateRef path text = do
  void $ runAff ignoreError ignoreError $ do
    state <- getModulesForFile port path text
    liftEff $ writeRef modulesStateRef state

moduleRegex :: Either String Regex
moduleRegex = regex """(?:^|[^A-Za-z_.])(?:((?:[A-Z][A-Za-z0-9]*\.)*(?:[A-Z][A-Za-z0-9]*))\.)?([a-zA-Z][a-zA-Z0-9_']*)?$""" noFlags

getCompletions :: forall eff. Int -> State -> Int -> Int -> GetText (MainEff eff)
  -> Eff (MainEff eff) (Promise (Array { suggestType :: String, typeInfo :: Command.TypeInfo }))
getCompletions port state line' char getTextInRange = do
  line <- getTextInRange line' 0 line' char
  let getQualifiedModule = (flip getQualModule) state
  config <- getConfiguration "purescript"
  autoCompleteAllModules <- either (const true) id <<< runExcept <<< readBoolean <$> getValue config "autocompleteAllModules"
  fromAff $ do
    modules <- if autoCompleteAllModules then getLoadedModules port else pure $ getUnqualActiveModules state Nothing
    suggestions <- C.getSuggestions port { line, moduleInfo: { modules, getQualifiedModule, mainModule: state.main } }
    pure $ convert <$> suggestions
  where
    -- TODO change the types here and pull in suggestion handling into PS
    convert (ModuleSuggestion { text, suggestType, prefix }) =
      { suggestType: convertSuggest suggestType, typeInfo: TypeInfo { type': text, identifier: text, module': text, expandedType: Just text, definedAt: Nothing, documentation: Nothing } }
    convert (IdentSuggestion { mod, identifier, qualifier, suggestType, prefix, valueType }) =
      { suggestType: convertSuggest suggestType, typeInfo: TypeInfo { type': valueType, identifier, module': mod, expandedType: Just valueType, definedAt: Nothing, documentation: Nothing } }

    convertSuggest = case _ of
      Module -> "Module"
      Value -> "Value"
      Function -> "Function"
      Type -> "Type"


type MarkedString = { language :: String, value :: String }

markedString :: String -> MarkedString
markedString s = { language: "purescript", value: s }

getTooltips :: forall eff. Int -> State -> Int -> Int -> GetText (MainEff eff)
  -> Eff (MainEff eff) (Promise (Nullable MarkedString))
getTooltips port state line char getTextInRange = do
    let beforeRegex = regex "[a-zA-Z_0-9']*$" noFlags
        afterRegex = regex "^[a-zA-Z_0-9']*" noFlags
    textBefore <- getTextInRange line 0    line char
    textAfter  <- getTextInRange line char line (char + 100)
    let word = case { before: match' beforeRegex textBefore, after: match' afterRegex textAfter } of
                { before: Just [Just s], after: Just [Just s'] } -> s<>s'
                _ -> ""
    fromAff do
      -- TODO current module for opened idents
      ty <- getType port word state.main Nothing (getUnqualActiveModules state $ Just word) (flip getQualModule $ state)
      let marked = if null ty then Nothing else Just $ markedString $ word <> " :: " <> ty
      pure $ toNullable marked

startServer' :: forall eff eff'. String -> Int -> String -> Notify (P.ServerEff (workspace :: WORKSPACE | eff)) -> Aff (P.ServerEff (workspace :: WORKSPACE | eff)) { port:: Maybe Int, quit:: P.QuitCallback eff' }
startServer' server _port root cb = do
  config <- liftEff $ getConfiguration "purescript"
  useNpmPath <- liftEff $ either (const false) id <<< runExcept <<< readBoolean <$> getValue config "addNpmPath"
  packagePath <- liftEff $ either (const "bower_components") id <<< runExcept <<< readString <$> getValue config "packagePath"
  P.startServer' root server useNpmPath ["src/**/*.purs", packagePath <> "/**/*.purs"] cb

toDiagnostic :: Boolean -> PscError -> FileDiagnostic
toDiagnostic isError (PscError { message, filename, position, suggestion }) =
  { filename: fromMaybe "" filename
  , diagnostic: mkDiagnostic (range position) message (if isError then 0 else 1)
  , quickfix: conv suggestion
  }
  where
  range (Just { startLine, startColumn, endLine, endColumn}) =
    mkRange
      (mkPosition (startLine-1) (startColumn-1))
      (mkPosition (endLine-1) (endColumn-1))
  range _ = mkRange (mkPosition 0 0) (mkPosition 0 0)

  conv (Just { replacement, replaceRange }) = { suggest: true, replacement, range: range replaceRange }
  conv _ = { suggest: false, replacement: "", range: range Nothing }

type FileDiagnostic =
  { filename :: String
  , diagnostic :: Diagnostic
  , quickfix :: { suggest :: Boolean, replacement :: String, range :: Range }
  }
type VSBuildResult =
  { success :: Boolean
  , diagnostics :: Array FileDiagnostic
  , quickBuild :: Boolean
  , file :: String
  }

data Status = Building | BuildFailure | BuildErrors | BuildSuccess

showStatus :: forall eff. Status -> Eff (window :: WINDOW | eff) Unit
showStatus status = do
  let icon = case status of
              Building -> "$(beaker)"
              BuildFailure -> "$(bug)"
              BuildErrors -> "$(check)"
              BuildSuccess -> "$(check)"
  setStatusBarMessage $ icon <> " PureScript"

quickBuild :: forall eff. Int -> String -> Eff (MainEff eff) (Promise VSBuildResult)
quickBuild port filename = fromAff $ do
  liftEff $ showStatus Building
  { errors, success } <- rebuild port filename
  liftEff $ showStatus BuildSuccess
  pure $ { success, diagnostics: toDiagnostic' errors, quickBuild: true, file: filename }

toDiagnostic' :: { warnings :: Array PscError, errors :: Array PscError } -> Array FileDiagnostic
toDiagnostic' { warnings, errors } = map (toDiagnostic true) errors <> map (toDiagnostic false) warnings

build' :: forall eff. Notify (MainEff eff) -> String -> String -> Eff (MainEff eff) (Promise VSBuildResult)
build' notify command directory = fromAff $ do
  liftEffM $ log "Building"
  let buildCommand = either (const []) (\reg -> (split reg <<< trim) command) (regex "\\s+" noFlags)
  case uncons buildCommand of
    Just { head: cmd, tail: args } -> do
      liftEffM $ log "Parsed build command"
      liftEffM $ showStatus Building
      config <- liftEff $ getConfiguration "purescript"
      useNpmDir <- liftEff $ either (const false) id <<< runExcept <<< readBoolean <$> getValue config "addNpmPath"
      res <- build { command: Command cmd args, directory, useNpmDir }
      liftEffM $ if res.success then showStatus BuildSuccess
                else showStatus BuildErrors
      pure $ { success: true, diagnostics: toDiagnostic' res.errors, quickBuild: false, file: "" }
    Nothing -> do
      liftEffM $ notify Error "Error parsing PureScript build command"
      liftEffM $ showStatus BuildFailure
      pure { success: false, diagnostics: [], quickBuild: false, file: "" }

addCompletionImport :: forall eff. (Ref State) -> Int -> Array Foreign -> Aff (MainEff eff) Unit
addCompletionImport stateRef port args = case args of
  [ line, char, item ] -> case runExcept $ readInt line, runExcept $ readInt char of
    Right line', Right char' -> do
      let item' = (unsafeCoerce item) :: Command.TypeInfo
      Command.TypeInfo { identifier, module' } <- pure item'
      ed <- liftEffM $ getActiveTextEditor
      case ed of
        Just ed' -> do
          let doc = getDocument ed'
          text <- liftEffM $ getText doc
          path <- liftEffM $ getPath doc
          state <- liftEffM $ readRef stateRef
          { state: newState, result: output} <- addExplicitImport state port path text (Just module') identifier
          liftEffM $ writeRef stateRef newState
          case output of
            UpdatedImports out -> void $ setTextViaDiff ed' out
            AmbiguousImport opts -> liftEffM $ log "Found ambiguous imports"
            FailedImport -> liftEffM $ log "Failed to import"
          pure unit
        Nothing -> pure unit
      pure unit
    _, _ -> liftEffM $ log "Wrong argument type"
  _ -> liftEffM $ log "Wrong command arguments"


main :: forall eff. Eff (MainEff eff)
  { activate :: Eff (MainEff eff) (Promise Unit)
  , deactivate :: Eff (MainEff eff) Unit
  , build :: EffFn2 (MainEff eff) String String (Promise VSBuildResult)
  , quickBuild :: EffFn1 (MainEff eff) String (Promise VSBuildResult)
  , updateFile :: EffFn2 (MainEff eff) String String Unit
  , getTooltips :: EffFn3 (MainEff eff) Int Int (EffFn4 (MainEff eff) Int Int Int Int String) (Promise (Nullable MarkedString))
  , getCompletions :: EffFn3 (MainEff eff) Int Int (EffFn4 (MainEff eff) Int Int Int Int String) (Promise (Array { suggestType :: String, typeInfo :: Command.TypeInfo }))
  , getSymbols :: EffFn1 (MainEff eff) String (Promise (Array SymbolInfo))
  , getSymbolsForDoc :: EffFn1 (MainEff eff) TextDocument (Promise (Array SymbolInfo))
  , provideDefinition :: EffFn3 (MainEff eff) Int Int (EffFn4 (MainEff eff) Int Int Int Int String) (Promise (Nullable Location))
  }
main = do
  modulesState <- newRef (initialModulesState)
  deactivateRef <- newRef (pure unit :: Eff (MainEff eff) Unit)
  portRef <- newRef 0

  let cmd s f = register ("purescript." <> s) (\_ -> f)
      cmdWithArgs s f = register ("purescript." <> s) f

  let deactivate :: Eff (MainEff eff) Unit
      deactivate = join (readRef deactivateRef)


  let showError :: Notify (MainEff eff)
      showError level str = case level of
                             Success -> Notify.showInfo str
                             Info -> Notify.showInfo str
                             Warning -> Notify.showWarning str
                             Error -> Notify.showError str

  let liftEffMM :: forall a. Eff (MainEff eff) a -> Aff (MainEff eff) a
      liftEffMM = liftEff

  let startPscIdeServer =
        do
          config <- liftEffMM $ getConfiguration "purescript"
          server <- liftEffMM $ either (const "psc-ide-server") id <<< runExcept <<< readString <$> getValue config "pscIdeServerExe"
          port' <- liftEffMM $ either (const 4242) id <<< runExcept <<< readInt <$> getValue config "pscIdePort"
          rootPath <- liftEffMM rootPath
          -- TODO pass in port just when explicitly defined
          startRes <- startServer' server port' rootPath showError
          retry case startRes of
            { port: Just port, quit } -> do
              P.load port [] []
              liftEffMM $ do
                writeRef deactivateRef quit
                writeRef portRef port
            _ -> pure unit
        where
          retry :: Aff (MainEff eff) Unit -> Aff (MainEff eff) Unit
          retry a = do
            res <- attempt a
            case res of
              Right r -> pure r
              Left err -> do
                liftEff $ log $ "Retrying starting server after 500ms: " <> show err
                later' 500 a


      restart :: Eff (MainEff eff) Unit
      restart = do
        deactivate
        void $ runAff ignoreError ignoreError $ startPscIdeServer

  let initialise = fromAff $ do
        startPscIdeServer
        liftEffMM do
          cmd "addImport" $ readRef portRef >>= addModuleImportCmd modulesState
          cmd "addExplicitImport" $ readRef portRef >>= addIdentImportCmd modulesState
          cmd "caseSplit" $ readRef portRef >>= caseSplit
          cmd "addClause" $ readRef portRef >>= addClause
          cmd "restartPscIde" $ restart
          cmdWithArgs "addCompletionImport" $ \args -> do
            port <- readRef portRef
            config <- getConfiguration "purescript"
            autocompleteAddImport <- either (const true) id <<< runExcept <<< readBoolean <$> getValue config "autocompleteAddImport"
            when autocompleteAddImport $
              void $ runAff ignoreError ignoreError $ addCompletionImport modulesState port args

  pure
    {
      activate: initialise
    , deactivate: deactivate
    , build: mkEffFn2 $ build' showError
    , quickBuild: mkEffFn1 \fname -> do
        port <- readRef portRef
        quickBuild port fname
    , updateFile: mkEffFn2 $ \fname text -> do
        port <- readRef portRef
        useEditor port modulesState fname text
    , getTooltips: mkEffFn3 $ \line char getText -> do
        state <- readRef modulesState
        port <- readRef portRef
        getTooltips port state line char (runEffFn4 getText)
    , getCompletions: mkEffFn3 $ \line char getText -> do
        state <- readRef modulesState
        port <- readRef portRef
        getCompletions port state line char (runEffFn4 getText)
    , getSymbols: mkEffFn1 $ \query -> getSymbols modulesState portRef $ WorkspaceSymbolQuery query
    , getSymbolsForDoc: mkEffFn1 $ \document -> getSymbols modulesState portRef $ FileSymbolQuery document
    , provideDefinition: mkEffFn3 $ \line char getText -> do
        state <- readRef modulesState
        port <- readRef portRef
        getDefinition port state line char (runEffFn4 getText)
    }
