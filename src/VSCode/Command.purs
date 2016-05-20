module VSCode.Command where

import Prelude
import Control.Monad.Eff (Eff)

foreign import data COMMAND :: !

foreign import register :: forall eff. String -> Eff (command :: COMMAND | eff) Unit -> Eff (command :: COMMAND | eff) Unit
