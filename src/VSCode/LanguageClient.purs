module VSCode.LanguageClient where

import Prelude

import Data.Either (Either(..))
import Data.Nullable (Nullable)
import Effect (Effect)
import Effect.Aff (Aff, Error, makeAff, nonCanceler)
import Foreign (Foreign)

foreign import data LanguageClient :: Type

foreign import sendCommandImpl :: forall a. LanguageClient -> String -> Nullable (Array Foreign) ->
  (Error -> Effect Unit) ->
  (a -> Effect Unit) -> 
  Effect Unit

sendCommand :: LanguageClient -> String -> Nullable (Array Foreign) -> Aff Foreign 
sendCommand lc cmd args = makeAff $ \cb -> sendCommandImpl lc cmd args (cb <<< Left) (cb <<< Right) $> nonCanceler

foreign import onNotification0 :: LanguageClient -> String -> Effect Unit -> Effect Unit
