module IdePurescript.VSCode.Symbols where

import PscIde.Command as Command
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Class (liftEff)
import Control.Monad.Eff.Ref (REF, Ref, readRef)
import Control.Promise (Promise, fromAff)
import Data.Array (mapMaybe, singleton)
import Data.Maybe (Maybe(Nothing, Just), maybe)
import Data.Nullable (toNullable, Nullable)
import IdePurescript.Modules (State, getQualModule, getUnqualActiveModules, getMainModule)
import IdePurescript.PscIde (getTypeInfo, getCompletion, getLoadedModules)
import IdePurescript.Tokens (identifierAtPoint)
import IdePurescript.VSCode.Editor (GetText)
import IdePurescript.VSCode.Types (MainEff)
import Prelude (bind, const, flip, pure, ($), (+), (-))
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

getSymbols :: forall s eff. Ref s -> Int -> SymbolQuery -> Eff ( ref :: REF, net :: NET, editor :: EDITOR| eff) (Promise (Array SymbolInfo))
getSymbols modulesState port query = do
  state <- readRef modulesState
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

    completions <- getCompletion port prefix Nothing Nothing modules (const [])

    let getInfo (Command.TypeInfo { identifier, definedAt: Just typePos, module', type' }) =
          Just { identifier, range: convTypePosition typePos, fileName: getName typePos, moduleName: module', identType: type' }
        getInfo _ = Nothing
        getName (Command.TypePosition { name }) = name
    pure $ mapMaybe getInfo completions

getDefinition :: forall eff. Int -> State -> Int -> Int -> GetText (MainEff eff)
  -> Eff (MainEff eff) (Promise (Nullable Location))
getDefinition port state line char getTextInRange = do
  text <- getTextInRange line 0 line (char + 100)
  case identifierAtPoint text char of
    Just { word, qualifier } -> fromAff do
      info <- getTypeInfo port word state.main qualifier (getUnqualActiveModules state $ Just word) (flip getQualModule $ state)
      pure $ toNullable $ case info of
        Just (Command.TypeInfo { definedAt: Just (Command.TypePosition { name, start }) }) -> Just $ mkLocation name $ convPosition start
        _ -> Nothing
    Nothing -> fromAff $ pure $ toNullable Nothing
