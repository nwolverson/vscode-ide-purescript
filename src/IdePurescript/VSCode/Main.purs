module IdePurescript.VSCode.Main where

import Prelude
import PscIde as P
import VSCode.Notifications as Notify
import Control.Monad.Aff (Aff, runAff)
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Class (liftEff)
import Control.Monad.Eff.Console (log)
import Control.Monad.Eff.Ref (REF, Ref, readRef, newRef, writeRef)
import Control.Promise (Promise, fromAff)
import Data.Array (uncons, head, length)
import Data.Either (Either, either)
import Data.Foldable (traverse_)
import Data.Function.Eff (EffFn4, EffFn3, EffFn2, EffFn1, runEffFn4, mkEffFn3, mkEffFn2, mkEffFn1)
import Data.Functor ((<$))
import Data.Maybe (Maybe(Just, Nothing), fromMaybe)
import Data.Posix.Signal (Signal(SIGKILL))
import Data.String (trim, null)
import Data.String.Regex (Regex, noFlags, regex, split)
import IdePurescript.Build (Command(Command), build, rebuild)
import IdePurescript.Modules (State, initialModulesState, getQualModule, getUnqualActiveModules, getModulesForFile, getMainModule)
import IdePurescript.PscErrors (PscError(PscError))
import IdePurescript.PscIde (getType, getCompletion, loadDeps)
import IdePurescript.PscIdeServer (ServerStartResult(..), startServer)
import IdePurescript.Regex (match')
import IdePurescript.VSCode.Assist (addClause, caseSplit)
import IdePurescript.VSCode.Imports (addModuleImportCmd, addIdentImportCmd)
import IdePurescript.VSCode.Types (MainEff)
import Node.ChildProcess (kill)
import Node.Process (lookupEnv)
import PscIde (NET)
import PscIde.Server (findBins, Executable(Executable))
import VSCode.Command (register)
import VSCode.Diagnostic (Diagnostic, mkDiagnostic)
import VSCode.Position (mkPosition)
import VSCode.Range (mkRange)

ignoreError :: forall a eff. a -> Eff eff Unit
ignoreError _ = pure unit

useEditor :: forall eff. Int -> (Ref State) -> String -> String -> Eff (net :: NET, ref :: REF | eff) Unit
useEditor port modulesStateRef path text = do
  let mainModule = getMainModule text
  case mainModule of
    Just m -> void $ runAff ignoreError ignoreError $ do
      loadDeps port m
      state <- getModulesForFile port path text
      liftEff $ writeRef modulesStateRef state
      pure unit
    Nothing -> pure unit

type GetText eff = Int -> Int -> Int -> Int -> Eff eff String -- TODO eff

moduleRegex :: Either String Regex
moduleRegex = regex """(?:^|[^A-Za-z_.])(?:((?:[A-Z][A-Za-z0-9]*\.)*(?:[A-Z][A-Za-z0-9]*))\.)?([a-zA-Z][a-zA-Z0-9_']*)?$""" noFlags

type Completion =
  { type:: String
  , identifier :: String
  , "module" :: String
  }

getCompletions :: forall eff. Int -> State -> Int -> Int -> GetText (MainEff eff)
  -> Eff (MainEff eff) (Promise (Array Completion))
getCompletions port state line char getTextInRange = do
  line <- getTextInRange line 0 line char
  let getQualifiedModule = (flip getQualModule) state
  let parsed = case match' moduleRegex line of
        Just [ Just _, mod, tok ] | mod /= Nothing || tok /= Nothing ->
          Just { mod: fromMaybe "" mod , token: fromMaybe "" tok}
        _ -> Nothing
  let moduleCompletion = false
  case parsed of
    Just { mod, token } -> fromAff $ do
      -- TODO currentModule
      getCompletion port token Nothing mod moduleCompletion (getUnqualActiveModules state $ Just token) getQualifiedModule
    _ -> fromAff $ pure []

getTooltips :: forall eff. Int -> State -> Int -> Int -> GetText (MainEff eff)
  -> Eff (MainEff eff) (Promise String)
getTooltips port state line char getTextInRange = do
    let beforeRegex = regex "[a-zA-Z_0-9']*$" noFlags
        afterRegex = regex "^[a-zA-Z_0-9']*" noFlags
    textBefore <- getTextInRange line 0    line char
    textAfter  <- getTextInRange line char line (char + 100)
    let word = case { before: match' beforeRegex textBefore, after: match' afterRegex textAfter } of
                { before: Just [Just s], after: Just [Just s'] } -> s<>s'
                _ -> ""
    let prefix = ""
    fromAff do
      -- TODO current module for opened idents
      ty <- getType port word Nothing prefix (getUnqualActiveModules state $ Just word) (flip getQualModule $ state)
      pure $ if null ty then "" else "**" <> word <> "** :: " <> ty

data ErrorLevel = Success | Info | Warning | Error
type Notify eff = ErrorLevel -> String -> Eff (MainEff eff) Unit

startServer' :: forall eff. String -> Int -> String -> Notify eff -> Aff (MainEff eff) (Maybe { port:: Int, quit:: Eff (MainEff eff) Unit })
startServer' server port root cb = do
  serverBins <- findBins server
  case head serverBins of
    Nothing -> do
      processPath <- liftEffS $ lookupEnv "PATH"
      liftEffS $ cb Info $ "Couldn't find psc-ide-server, check PATH. Looked for: "
        <> server <> " in PATH: " <> fromMaybe "" processPath
      pure Nothing
    Just (Executable bin _) -> do
      -- TODO: Configure globs
      -- TODO: add port config override
      res <- startServer bin root ["src/**/*.purs", "bower_components/purescript-*/src/**/*.purs"]
      liftEff $ log $ "Resolved psc-ide-server:"
      traverse_ (\(Executable x vv) -> do
        liftEff $ log $ x <> ": " <> fromMaybe "ERROR" vv) serverBins
      liftEff $ when (length serverBins > 1) $ cb Warning $ "Found multiple psc-ide-server executables; using " <> bin

      liftEff $ case res of
        CorrectPath port -> Just { port, quit: pure unit } <$ cb Info "Found existing psc-ide-server with correct path"
        WrongPath port wrongPath -> Nothing <$ (cb Error $ "Found existing psc-ide-server with wrong path: '" <>wrongPath<>"'. Correct, kill or configure a different port, and restart.")
        Started port cp -> Just { port, quit: void $ kill SIGKILL cp } <$ cb Success ("Started psc-ide-server on " <> show port)
        Closed -> Nothing <$ cb Info "psc-ide-server exited with success code"
        StartError err -> Nothing <$ (cb Error $ "Could not start psc-ide-server process. Check the configured port number is valid.\n" <>err)

  where
    liftEffS :: forall a. Eff (MainEff eff) a -> Aff (MainEff eff) a
    liftEffS = liftEff

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

  -- TODO: Handle suggestion ranges (_)
  conv (Just { replacement }) = { suggest: true, replacement }
  conv _ = { suggest: false, replacement: "" }

type FileDiagnostic =
  { filename :: String
  , diagnostic :: Diagnostic
  , quickfix :: { suggest :: Boolean, replacement :: String }
  }
type VSBuildResult =
  { success:: Boolean
  , diagnostics :: Array FileDiagnostic
  }

quickBuild :: forall eff. Int -> String -> Eff (MainEff eff) (Promise VSBuildResult)
quickBuild port filename = fromAff $ do
  { errors, success } <- rebuild port filename
  liftEff $  log $ "Quick build done: " <> show success
  pure $ { success, diagnostics: toDiagnostic' errors }

toDiagnostic' :: { warnings :: Array PscError, errors :: Array PscError } -> Array FileDiagnostic
toDiagnostic' { warnings, errors } = map (toDiagnostic true) errors <> map (toDiagnostic false) warnings

build' :: forall eff. Notify eff -> String -> String -> Eff (MainEff eff) (Promise VSBuildResult)
build' notify command directory = fromAff $ do
  liftEff $ log "Building"
  let buildCommand = either (const []) (\reg -> (split reg <<< trim) command) (regex "\\s+" noFlags)
  case uncons buildCommand of
    Just { head: cmd, tail: args } -> do
      liftEff $ log "Parsed build command"
      liftEff $ notify Info "Building PureScript"
      res <- build { command: Command cmd args, directory }
      liftEff $ if res.success then notify Success "PureScript build succeeded"
                else notify Warning "PureScript build completed with errors"
      pure $ { success: true, diagnostics: toDiagnostic' res.errors }
    Nothing -> do
      liftEff $ notify Error "Error parsing PureScript build command"
      pure { success: false, diagnostics: [] }

main :: forall eff. Eff (MainEff eff)
  { activate :: EffFn3 (MainEff eff) String Int String (Promise Unit)
  , deactivate :: Eff (MainEff eff) Unit
  , build :: EffFn2 (MainEff eff) String String (Promise VSBuildResult)
  , quickBuild :: EffFn1 (MainEff eff) String (Promise VSBuildResult)
  , updateFile :: EffFn2 (MainEff eff) String String Unit
  , getTooltips :: EffFn3 (MainEff eff) Int Int (EffFn4 (MainEff eff) Int Int Int Int String) (Promise String)
  , getCompletions :: EffFn3 (MainEff eff) Int Int (EffFn4 (MainEff eff) Int Int Int Int String) (Promise (Array Completion))
  }
main = do
  modulesState <- newRef (initialModulesState)
  deactivateRef <- newRef (pure unit :: Eff (MainEff eff) Unit)
  portRef <- newRef 0

  let cmd s f = register ("purescript." <> s) f

  let deactivate :: Eff (MainEff eff) Unit
      deactivate = join (readRef deactivateRef)

  let showError :: Notify eff
      showError level str = case level of
                             Success -> Notify.showInfo str
                             Info -> Notify.showInfo str
                             Warning -> Notify.showWarning str
                             Error -> Notify.showError str

  let liftEffMM :: forall a. Eff (MainEff eff) a -> Aff (MainEff eff) a
      liftEffMM = liftEff
  let initialise server _port root = fromAff do
        -- TODO pass in port just when explicitly defined
        startRes <- startServer' server _port root showError
        case startRes of
          Just { port, quit } -> do
            P.load port [] []
            liftEffMM $ do
              cmd "addImport" $ readRef portRef >>= addModuleImportCmd modulesState
              cmd "addExplicitImport" $ readRef portRef >>= addIdentImportCmd modulesState
              cmd "caseSplit" $ readRef portRef >>= caseSplit
              cmd "addClause" $ readRef portRef >>= addClause
              writeRef deactivateRef quit
              writeRef portRef port
          Nothing -> pure unit

  pure
    {
      activate: mkEffFn3 initialise
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
    }
