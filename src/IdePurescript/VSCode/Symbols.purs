module IdePurescript.VSCode.Symbols where

import Prelude (pure, flip, bind, const, ($), (<>), (+), (-))
import PscIde.Command as Command
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Class (liftEff)
import Control.Monad.Eff.Ref (REF, Ref, readRef)
import Control.Promise (Promise, fromAff)
import Data.Array (mapMaybe, singleton)
import Data.Functor ((<$))
import Data.Maybe (Maybe(Nothing, Just), maybe)
import Data.Nullable (toNullable, Nullable)
import Data.String.Regex (noFlags, regex)
import IdePurescript.Modules (State, getQualModule, getUnqualActiveModules, getMainModule)
import IdePurescript.PscIde (getTypeInfo, getCompletion, getLoadedModules)
import IdePurescript.Regex (match')
import IdePurescript.VSCode.Types (MainEff)
import IdePurescript.VSCode.Editor (GetText)
import PscIde (NET)
import VSCode.Location (Location, mkLocation)
import VSCode.Position (mkPosition, Position)
import VSCode.Range (mkRange, Range)
import VSCode.TextDocument (EDITOR, TextDocument, getText)

type SymbolInfo = { identifier :: String, range :: Range, fileName :: String, moduleName :: String, identType :: String }
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

    let getInfo (Command.TypeInfo { identifier, definedAt: Just typePos, module', type' }) =
          Just { identifier, range: convTypePosition typePos, fileName: getName typePos, moduleName: module', identType: type' } 
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