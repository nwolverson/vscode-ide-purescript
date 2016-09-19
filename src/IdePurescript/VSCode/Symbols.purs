module IdePurescript.VSCode.Symbols where

import Prelude
import PscIde.Command as Command
import VSCode.Notifications as Notify
import Control.Monad.Aff (Aff, runAff)
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Class (liftEff)
import Control.Monad.Eff.Console (log)
import Control.Monad.Eff.Ref (REF, Ref, readRef, newRef, writeRef)
import Control.Promise (Promise, fromAff)
import Data.Array (singleton, mapMaybe, uncons)
import Data.Either (Either(..), either)
import Data.Foreign (readInt, readString, readBoolean, Foreign)
import Data.Function.Eff (EffFn4, EffFn3, EffFn2, EffFn1, runEffFn4, mkEffFn3, mkEffFn2, mkEffFn1)
import Data.Functor ((<$))
import Data.Maybe (maybe, Maybe(Just, Nothing), fromMaybe)
import Data.Nullable (toNullable, Nullable)
import Data.String (trim, null)
import Data.String.Regex (Regex, noFlags, regex, split)
import IdePurescript.Build (Command(Command), build, rebuild)
import IdePurescript.Modules (ImportResult(FailedImport, AmbiguousImport, UpdatedImports), addExplicitImport, State, initialModulesState, getQualModule, getUnqualActiveModules, getModulesForFile, getMainModule)
import IdePurescript.PscErrors (PscError(PscError))
import IdePurescript.PscIde (getLoadedModules, getType, getTypeInfo, getCompletion, loadDeps)
import IdePurescript.PscIdeServer (Notify, ErrorLevel(Error, Warning, Info, Success))
import IdePurescript.PscIdeServer (startServer', QuitCallback, ServerEff) as P
import IdePurescript.Regex (match')
import IdePurescript.VSCode.Assist (addClause, caseSplit)
import IdePurescript.VSCode.Imports (addModuleImportCmd, addIdentImportCmd)
import IdePurescript.VSCode.Types (MainEff, liftEffM)
import IdePurescript.VSCode.Editor
import PscIde (load) as P
import PscIde (NET)
import Unsafe.Coerce (unsafeCoerce)
import VSCode.Command (register)
import VSCode.Diagnostic (Diagnostic, mkDiagnostic)
import VSCode.Location (Location, mkLocation)
import VSCode.Position (mkPosition, Position)
import VSCode.Range (mkRange, Range)
import VSCode.TextDocument (EDITOR, TextDocument, getPath, getText)
import VSCode.TextEditor (setTextViaDiff, getDocument)
import VSCode.Window (getActiveTextEditor, setStatusBarMessage, WINDOW)
import VSCode.Workspace (rootPath, getValue, getConfiguration, WORKSPACE)

type SymbolInfo = { identifier :: String, range :: Range, fileName :: String, moduleName :: String }
data SymbolQuery = WorkspaceSymbolQuery String | FileSymbolQuery TextDocument

convPosition :: Command.Position -> Position
convPosition { line, column } = mkPosition (line-1) (column-1)

convTypePosition :: Command.TypePosition -> Range
convTypePosition (Command.TypePosition {start, end}) = mkRange (convPosition start) (convPosition end)


getSymbols :: forall s eff. Ref s -> Ref Int -> SymbolQuery -> Eff ( ref :: REF, net :: NET, editor :: EDITOR| eff) (Promise (Array SymbolInfo))
getSymbols modulesState portRef query = do
  state <- readRef modulesState
  port <- readRef portRef
  fromAff $ do
    let prefix = case query of 
                    WorkspaceSymbolQuery pref -> pref
                    FileSymbolQuery _ -> ""
    modules <- case query of
      WorkspaceSymbolQuery _ -> getLoadedModules port
      FileSymbolQuery document -> liftEff do
        text <- getText document
        let mod = getMainModule text
        pure $ maybe [] singleton mod

    completions <- getCompletion port prefix Nothing "" false modules (const [])

    let getInfo (Command.TypeInfo { identifier, definedAt: Just typePos, module' }) =
          Just { identifier, range: convTypePosition typePos, fileName: getName typePos, moduleName: module' } 
        getInfo _ = Nothing
        getName (Command.TypePosition { name }) = name
    pure $ mapMaybe getInfo completions



getDefinition :: forall eff. Int -> State -> Int -> Int -> GetText (MainEff eff)
  -> Eff (MainEff eff) (Promise (Nullable Location))
getDefinition port state line char getTextInRange = do
  let beforeRegex = regex "[a-zA-Z_0-9']*$" noFlags
      afterRegex = regex "^[a-zA-Z_0-9']*" noFlags
  textBefore <- getTextInRange line 0    line char
  textAfter  <- getTextInRange line char line (char + 100)
  let word = case { before: match' beforeRegex textBefore, after: match' afterRegex textAfter } of
              { before: Just [Just s], after: Just [Just s'] } -> s<>s'
              _ -> ""
  let prefix = ""
  fromAff $ do
    info <- getTypeInfo port word Nothing prefix (getUnqualActiveModules state $ Just word) (flip getQualModule $ state)
    pure $ toNullable $ case info of
      Just (Command.TypeInfo { definedAt: Just (Command.TypePosition { name, start }) }) -> Just $ mkLocation name $ convPosition start
      _ -> Nothing
