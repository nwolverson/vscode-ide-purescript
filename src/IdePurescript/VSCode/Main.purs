module IdePurescript.VSCode.Main where

import Prelude
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (CONSOLE, log, error)
import Control.Monad.Eff.Ref (REF, Ref, readRef, newRef, writeRef)
import Control.Monad.Eff.Class (liftEff)
import Data.Function.Eff (EffFn4, EffFn3, EffFn2, runEffFn4, mkEffFn3, mkEffFn2)
import Control.Monad.Aff (Aff, runAff)
import Control.Monad.Aff.AVar (AVAR)
import Data.Functor ((<$))
import Control.Bind (join)
import Data.Maybe (Maybe(Just, Nothing), fromMaybe)
import Data.String.Regex (Regex, match, noFlags, regex)
import Data.String (null)
import Control.Monad.Aff (runAff)
import PscIde (NET)
import Control.Promise (Promise, fromAff)
import Data.String.Regex (Regex, noFlags, regex, split, match)
import Data.String (trim)
import Data.Posix.Signal (Signal(SIGKILL))
import Data.Array (uncons)

import Node.ChildProcess (kill, CHILD_PROCESS)

import IdePurescript.Build (Command(Command), build)
import IdePurescript.PscErrors (PscError)
import IdePurescript.Modules (State, initialModulesState, getQualModule, getUnqualActiveModules, getModulesForFile, getMainModule)
import IdePurescript.PscIde (getType, getCompletion, loadDeps)
import IdePurescript.PscIdeServer (ServerStartResult(StartError, Closed, Started, WrongPath, CorrectPath), startServer)

import VSCode.Position (mkPosition)
import VSCode.Range (mkRange)
import VSCode.Diagnostic (Diagnostic, mkDiagnostic)

type MainEff =
  ( console :: CONSOLE
  , net :: NET
  , ref :: REF
  , avar :: AVAR
  , cp :: CHILD_PROCESS
  )

ignoreError :: forall a eff. a -> Eff eff Unit
ignoreError _ = pure unit

useEditor :: forall eff. (Ref State) -> String -> String -> Eff (net :: NET, ref :: REF | eff) Unit
useEditor modulesStateRef path text = do
  let mainModule = getMainModule text
  case mainModule of
    Just m -> runAff ignoreError ignoreError $ do
      loadDeps m
      state <- getModulesForFile path text
      liftEff $ writeRef modulesStateRef state
      pure unit
    Nothing -> pure unit

type GetText eff = Int -> Int -> Int -> Int -> Eff eff String -- TODO eff


moduleRegex :: Regex
moduleRegex = regex """(?:^|[^A-Za-z_.])(?:((?:[A-Z][A-Za-z0-9]*\.)*(?:[A-Z][A-Za-z0-9]*))\.)?([a-zA-Z][a-zA-Z0-9_']*)?$""" noFlags

type Completion =
  { type:: String
  , identifier :: String
  }

getCompletions :: State -> Int -> Int -> GetText MainEff
  -> Eff MainEff (Promise (Array Completion))
getCompletions state line char getTextInRange = do
  line <- getTextInRange line 0 line char
  let modules = getUnqualActiveModules state
      getQualifiedModule = (flip getQualModule) state
  let parsed =
      case match moduleRegex line of
        Just [ Just _, mod, tok ] | mod /= Nothing || tok /= Nothing ->
          Just { mod: fromMaybe "" mod , token: fromMaybe "" tok}
        _ -> Nothing
  let moduleCompletion = false
  log $ line
  case parsed of
    Just { mod, token } -> fromAff $ do
      getCompletion token mod moduleCompletion modules getQualifiedModule
    _ -> fromAff $ pure []

getTooltips :: State -> Int -> Int -> GetText MainEff
  -> Eff MainEff (Promise String)
getTooltips state line char getTextInRange = do
    let beforeRegex = regex "[a-zA-Z_0-9']*$" noFlags
        afterRegex = regex "^[a-zA-Z_0-9']*" noFlags
    textBefore <- getTextInRange line 0    line char
    textAfter  <- getTextInRange line char line (char + 100)
    let word = case { before: match beforeRegex textBefore, after: match afterRegex textAfter } of
                { before: Just [Just s], after: Just [Just s'] } -> s++s'
                _ -> ""
    let prefix = ""
    fromAff do
      ty <- getType word prefix (getUnqualActiveModules state) (flip getQualModule $ state)
      pure $ if null ty then "" else "**" ++ word ++ "** :: " ++ ty

data ErrorLevel = Success | Info | Warning | Error
type Notify = ErrorLevel -> String -> Eff MainEff Unit

startServer' :: String -> Int -> String -> Notify -> Aff MainEff (Eff MainEff Unit)
startServer' server port root cb = do
  res <- startServer server port root
  childProc <- liftEff $ case res of
    CorrectPath -> Nothing <$ cb Info "Found existing psc-ide-server with correct path"
    WrongPath wrongPath -> Nothing <$ (cb Error $ "Found existing psc-ide-server with wrong path: '" ++wrongPath++"'. Correct, kill or configure a different port, and restart.")
    Started cp -> Just cp <$ cb Success "Started psc-ide-server"
    Closed -> Nothing <$ cb Info "psc-ide-server exited with success code"
    StartError err -> Nothing <$ (cb Error $ "Could not start psc-ide-server process. Check the configured port number is valid.\n" ++err)
  case childProc of
    Nothing -> pure $ pure unit
    Just cp -> pure $ void $ kill SIGKILL cp

toDiagnostic :: Boolean -> PscError -> FileDiagnostic
toDiagnostic isError (pscerr@{ message, filename, position, suggestion }) =
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

  conv (Just replacement) = { suggest: true, replacement }
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

build' :: Notify -> String -> String -> Eff MainEff (Promise VSBuildResult)
build' notify command directory  = fromAff $ do
  liftEff $ log "Building"
  let buildCommand = (split (regex "\\s+" noFlags) <<< trim) command
  case uncons buildCommand of
    Just { head: cmd, tail: args } -> do
      liftEff $ log "Parsed build command"
      liftEff $ notify Info "Building PureScript"
      res <- build { command: Command cmd args, directory }
      liftEff $ if res.success then notify Success "PureScript build succeeded"
                else notify Warning "PureScript build completed with errors"
      pure $ { success: true, diagnostics: map (toDiagnostic true) res.errors.errors ++ map (toDiagnostic false) res.errors.warnings }
    Nothing -> do
      liftEff $ notify Error "Error parsing PureScript build command"
      pure { success: false, diagnostics: [] }

main :: Eff MainEff
  { activate :: EffFn3 MainEff String Int String (Promise Unit)
  , deactivate :: Eff MainEff Unit
  , build :: EffFn2 MainEff String String (Promise VSBuildResult)
  , updateFile :: EffFn2 MainEff String String Unit
  , getTooltips :: EffFn3 MainEff Int Int (EffFn4 MainEff Int Int Int Int String) (Promise String)
  , getCompletions :: EffFn3 MainEff Int Int (EffFn4 MainEff Int Int Int Int String) (Promise (Array Completion))
  }
main = do
  modulesState <- newRef (initialModulesState)
  deactivateRef <- newRef (pure unit :: Eff MainEff Unit)


  let deactivate :: Eff MainEff Unit
      deactivate = join (readRef deactivateRef)

  let logError level str = case level of
                            Success -> log str
                            Info -> log str
                            Warning -> log str
                            Error -> error str

  let initialise server port root = fromAff do
        deact <- startServer' server port root logError
        liftEff $ writeRef deactivateRef deact

  pure
    {
      activate: mkEffFn3 initialise
    , deactivate: deactivate
    , build: mkEffFn2 $ build' logError
    , updateFile: mkEffFn2 $ \fname text -> useEditor modulesState fname text
    , getTooltips: mkEffFn3 $ \line char getText -> do
        state <- readRef modulesState
        getTooltips state line char (runEffFn4 getText)
    , getCompletions: mkEffFn3 $ \line char getText -> do
        state <- readRef modulesState
        getCompletions state line char (runEffFn4 getText)
    }
