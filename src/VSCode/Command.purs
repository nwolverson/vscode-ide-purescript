module VSCode.Command where

import Prelude
import Control.Monad.Eff (Eff)
import Data.Foreign (Foreign)

foreign import data COMMAND :: !

foreign import register :: forall eff. String -> (Array Foreign -> Eff (command :: COMMAND | eff) Unit) -> Eff (command :: COMMAND | eff) Unit
