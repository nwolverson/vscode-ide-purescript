module IdePurescript.VSCode.Symbols where

import Prelude
import PscIde.Command as Command
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Class (liftEff)
import Control.Monad.Eff.Ref (REF, Ref, readRef)
import Control.Promise (Promise, fromAff)
import Data.Array (catMaybes, singleton)
import Data.Maybe (Maybe(Nothing, Just), maybe)
import Data.Nullable (toNullable, Nullable)
import Data.Traversable (traverse)
import IdePurescript.Modules (State, getQualModule, getUnqualActiveModules, getMainModule)
import IdePurescript.PscIde (getTypeInfo, getCompletion, getLoadedModules)
import IdePurescript.Tokens (identifierAtPoint)
import IdePurescript.VSCode.Editor (GetText)
import IdePurescript.VSCode.Types (MainEff)
import Node.Path (FilePath, resolve)
import PscIde (NET)
import VSCode.Location (Location, mkLocation)
import VSCode.Position (mkPosition, Position)
import VSCode.Range (mkRange, Range)
import VSCode.TextDocument (EDITOR, TextDocument, getText)
import VSCode.Workspace (WORKSPACE, rootPath)

type SymbolInfo = { identifier :: String, range :: Range, fileName :: String, moduleName :: String, identType :: String }
data SymbolQuery = WorkspaceSymbolQuery String | FileSymbolQuery TextDocument

convPosition :: Command.Position -> Position
convPosition { line, column } = mkPosition (line-1) (column-1)

convTypePosition :: Command.TypePosition -> Range
convTypePosition (Command.TypePosition {start, end}) = mkRange (convPosition start) (convPosition end)

resolveFile :: forall e. FilePath -> Eff (workspace :: WORKSPACE | e) FilePath
resolveFile p = do 
  root <- rootPath
  pure $ resolve [ root ] p

getSymbols :: forall s eff. Ref s -> Int -> SymbolQuery -> Eff ( ref :: REF, net :: NET, editor :: EDITOR, workspace :: WORKSPACE | eff) (Promise (Array SymbolInfo))
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

    let getInfo (Command.TypeInfo { identifier, definedAt: Just typePos, module', type' }) = do
          fileName <- getName typePos
          pure $ Just { identifier, range: convTypePosition typePos, fileName, moduleName: module', identType: type' }
        getInfo _ = pure Nothing
        getName (Command.TypePosition { name }) = resolveFile name
    
    res <- liftEff $ traverse getInfo completions
    pure $ catMaybes res

getDefinition :: forall eff. Int -> State -> Int -> Int -> GetText (MainEff eff)
  -> Eff (MainEff eff) (Promise (Nullable Location))
getDefinition port state line char getTextInRange = do
  text <- getTextInRange line 0 line (char + 100)
  case identifierAtPoint text char of
    Just { word, qualifier } -> fromAff do
      info <- getTypeInfo port word state.main qualifier (getUnqualActiveModules state $ Just word) (flip getQualModule $ state)
      liftEff $ toNullable <$> case info of
        Just (Command.TypeInfo { definedAt: Just (Command.TypePosition { name, start }) }) -> do
          fileName <- resolveFile name
          pure $ Just $ mkLocation fileName $ convPosition start
        _ -> pure $ Nothing
    Nothing -> fromAff $ pure $ toNullable Nothing
