module VSCode.Command where

import Prelude
import Control.Monad.Eff (Eff, kind Effect)
import Data.Foreign (Foreign)

foreign import data COMMAND :: Effect

foreign import register :: forall eff. String -> (Array Foreign -> Eff (command :: COMMAND | eff) Unit) -> Eff (command :: COMMAND | eff) Unit
