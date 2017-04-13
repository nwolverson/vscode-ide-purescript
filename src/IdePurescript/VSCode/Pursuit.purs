module IdePurescript.VSCode.Pursuit where

import Prelude
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Class (liftEff)
import Control.Monad.Eff.Exception (EXCEPTION)
import Data.Either (either)
import Data.Traversable (traverse)
import IdePurescript.VSCode.Types (launchAffAndRaise)
import Node.StripTags (stripTags)
import PscIde (NET, pursuitCompletion)
import PscIde.Command (PursuitCompletion(..))
import VSCode.Input (DIALOG, defaultInputOptions, getInput, showQuickPickItems)

searchPursuit :: forall eff. Int -> Eff (dialog :: DIALOG, net :: NET, exception :: EXCEPTION | eff) Unit
searchPursuit port = launchAffAndRaise do
    searchTerm <- getInput defaultInputOptions
    res <- either (const []) id <$> pursuitCompletion port searchTerm
    items <- liftEff $ traverse item res
    _ <- showQuickPickItems items
    pure unit

    where
    item (PursuitCompletion { identifier, module', text }) = do
        processed <- stripTags text
        pure $
            { description: module'
            , label: identifier
            , detail: processed
            }
