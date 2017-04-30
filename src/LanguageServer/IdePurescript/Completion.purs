module LanguageServer.IdePurescript.Completion where

import Prelude
import LanguageServer.IdePurescript.Config as Config
import LanguageServer.Types as LS
import Control.Monad.Aff (Aff)
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Class (liftEff)
import Control.Promise (Promise, fromAff)
import Data.Maybe (Maybe(..))
import Data.Newtype (over, un, unwrap)
import Data.Nullable (toNullable)
import Data.String (length)
import IdePurescript.Completion (SuggestionResult(..), SuggestionType(..), getSuggestions)
import IdePurescript.Modules (getQualModule, getUnqualActiveModules)
import IdePurescript.PscIde (getLoadedModules)
import LanguageServer.DocumentStore (getDocument)
import LanguageServer.Handlers (TextDocumentPositionParams, Res)
import LanguageServer.IdePurescript.Types (MainEff, ServerState(..))
import LanguageServer.TextDocument (getTextAtRange)
import LanguageServer.Types (CONN, CompletionItem(..), DocumentStore, Position(..), Range(..), Settings, TextDocumentIdentifier(..), TextEdit(..), completionItem)

getCompletions :: forall eff. DocumentStore -> Settings -> ServerState (MainEff eff) -> TextDocumentPositionParams -> Aff (MainEff eff) (Array CompletionItem)
getCompletions docs settings state ({ textDocument, position }) = do
    doc <- liftEff $ getDocument docs (_.uri $ un TextDocumentIdentifier textDocument)
    line <- liftEff $ getTextAtRange doc (mkRange position)
    let autoCompleteAllModules = Config.autoCompleteAllModules settings
        { port, modules } = unwrap state
        getQualifiedModule = (flip getQualModule) modules

    case port of
        Just port' ->  do
            usedModules <- if autoCompleteAllModules
                then getLoadedModules port'
                else pure $ getUnqualActiveModules modules Nothing
            suggestions <- getSuggestions port' 
                { line
                , moduleInfo: { modules: usedModules, getQualifiedModule, mainModule: modules.main }
                }
            pure $ convert <$> suggestions
        _ -> pure []

    where
    mkRange (pos@ Position { line, character }) = Range 
        { start: pos # over Position (_ { character = 0 })
        , end: pos
        }

    convertSuggest = case _ of
      Module -> LS.Module
      Value -> LS.Value
      Function -> LS.Function
      Type -> LS.Class

    convert (ModuleSuggestion { text, suggestType, prefix }) = completionItem text (convertSuggest suggestType)
    convert (IdentSuggestion { mod, identifier, qualifier, suggestType, prefix, valueType }) =
        completionItem identifier (convertSuggest suggestType) 
        # over CompletionItem (_
          { detail = toNullable $ Just valueType
          , documentation = toNullable $ Just mod
        --   , textEdit = toNullable $ Just edit
          })
        where 
        edit = TextEdit
            { range: Range
                { start: position # over Position (\pos -> pos { character = pos.character - length prefix })
                , end: position
                }
            , newText: identifier
            }
