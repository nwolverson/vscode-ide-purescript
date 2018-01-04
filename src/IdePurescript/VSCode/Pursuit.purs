module IdePurescript.VSCode.Pursuit where

import Prelude

import Control.Monad.Aff.Console (CONSOLE, log)
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Class (liftEff)
import Control.Monad.Eff.Exception (EXCEPTION)
import Data.Array (length)
import Data.Maybe (fromMaybe)
import Data.Traversable (traverse)
import IdePurescript.Pursuit (PursuitSearchInfo(..), PursuitSearchResult(..), pursuitModuleSearchRequest, pursuitSearchRequest)
import IdePurescript.VSCode.Types (launchAffAndRaise)
import Network.HTTP.Affjax (AJAX)
import Node.StripTags (stripTags)
import VSCode.Input (DIALOG, defaultInputOptions, getInput, showQuickPickItems)

searchPursuit :: forall eff. Eff (dialog :: DIALOG, ajax :: AJAX , console :: CONSOLE, exception :: EXCEPTION | eff) Unit
searchPursuit = launchAffAndRaise do
    searchTerm <- getInput defaultInputOptions
    results <- pursuitSearchRequest searchTerm
    items <- liftEff $ traverse item results
    void $ showQuickPickItems items

    where
    item (PursuitSearchResult { text, package, info: PursuitSearchInfo { mod, title }  }) = do
        processed <- stripTags text
        pure $
            { description: fromMaybe "" mod
            , label: fromMaybe "" title
            , detail: processed
            }

searchPursuitModules :: forall eff. Eff (dialog :: DIALOG, ajax :: AJAX , console :: CONSOLE, exception :: EXCEPTION | eff) Unit
searchPursuitModules = launchAffAndRaise do
    searchTerm <- getInput defaultInputOptions
    results <- pursuitModuleSearchRequest searchTerm
    items <- liftEff $ traverse item results
    void $ showQuickPickItems items

    where
    item (PursuitSearchResult { package, info: PursuitSearchInfo { mod }  }) = do
        pure $
            { description: ""
            , label: fromMaybe "" mod
            , detail: package
            }
