module VSCode.LanguageClient where

import Prelude
import Control.Monad.Aff (Aff, makeAff)
import Control.Monad.Eff (Eff, kind Effect)
import Control.Monad.Eff.Exception (Error)
import Data.Foreign (Foreign)
import Data.Nullable (Nullable)
import VSCode.Command (COMMAND)

foreign import data LanguageClient :: Type

foreign import sendCommandImpl :: forall eff a. LanguageClient -> String -> Nullable (Array Foreign) ->
  (Error -> Eff (command :: COMMAND | eff) Unit) ->
  (a -> Eff (command :: COMMAND | eff) Unit) -> 
  Eff (command :: COMMAND | eff) Unit

sendCommand :: forall eff. LanguageClient -> String -> Nullable (Array Foreign) -> Aff (command :: COMMAND | eff) Foreign 
sendCommand lc cmd args = makeAff $ sendCommandImpl lc cmd args

foreign import onNotification0 :: forall eff a. LanguageClient -> String -> Eff (command :: COMMAND | eff) Unit -> Eff (command :: COMMAND | eff) Unit
