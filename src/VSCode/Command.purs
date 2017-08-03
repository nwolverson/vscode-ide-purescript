module VSCode.Command where

import Prelude
import Control.Monad.Aff (Aff, makeAff)
import Control.Monad.Eff (Eff, kind Effect)
import Control.Promise (Promise)
import Data.Foreign (Foreign)

foreign import data COMMAND :: Effect

foreign import register :: forall eff. String -> (Array Foreign -> Eff (command :: COMMAND | eff) Unit) -> Eff (command :: COMMAND | eff) Unit

foreign import execute :: forall eff. String -> Array Foreign -> Eff (command :: COMMAND | eff) (Promise Unit)

foreign import executeCb :: forall eff a. String -> Array Foreign -> (a -> Eff (command :: COMMAND | eff) Unit) -> Eff (command :: COMMAND | eff) Unit

executeAff :: forall eff a. String -> Array Foreign -> Aff (command :: COMMAND | eff) a
executeAff a b =
  makeAff \err succ -> executeCb a b succ
