module IdePurescript.VSCode.Pursuit where

import Prelude

import Data.Maybe (fromMaybe)
import Data.Traversable (traverse)
import Effect (Effect)
import Effect.Class (liftEffect)
import IdePurescript.VSCode.Types (launchAffAndRaise)
import Node.StripTags (stripTags)
import Pursuit (PursuitSearchInfo(..), PursuitSearchResult(..), pursuitModuleSearchRequest, pursuitSearchRequest)
import VSCode.Input (defaultInputOptions, getInput, showQuickPickItems)

searchPursuit :: Effect Unit
searchPursuit = launchAffAndRaise do
    searchTerm <- getInput defaultInputOptions
    results <- pursuitSearchRequest searchTerm
    items <- liftEffect $ traverse item results
    void $ showQuickPickItems items

    where
    item (PursuitSearchResult { text, package, info: PursuitSearchInfo { mod, title }  }) = do
        processed <- stripTags text
        pure $
            { description: fromMaybe "" mod
            , label: fromMaybe "" title
            , detail: processed
            }

searchPursuitModules :: Effect Unit
searchPursuitModules = launchAffAndRaise do
    searchTerm <- getInput defaultInputOptions
    results <- pursuitModuleSearchRequest searchTerm
    items <- liftEffect $ traverse item results
    void $ showQuickPickItems items

    where
    item (PursuitSearchResult { package, info: PursuitSearchInfo { mod }  }) = do
        pure $
            { description: ""
            , label: fromMaybe "" mod
            , detail: package
            }
