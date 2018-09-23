module VSCode.Command where

import Prelude

import Control.Promise (Promise)
import Data.Either (Either(..))
import Effect (Effect)
import Effect.Aff (Aff, makeAff, nonCanceler)
import Foreign (Foreign)

foreign import register :: String -> (Array Foreign -> Effect Unit) -> Effect Unit

foreign import execute :: String -> Array Foreign -> Effect (Promise Unit)

foreign import executeCb :: forall a. String -> Array Foreign -> (a -> Effect Unit) -> Effect Unit

executeAff :: forall a. String -> Array Foreign -> Aff a
executeAff a b = makeAff \cb -> executeCb a b (cb <<< Right) $> nonCanceler
