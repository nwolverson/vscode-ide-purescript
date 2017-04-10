module VSCode.Notifications where

import Prelude (Unit)
import Control.Monad.Eff

foreign import data NOTIFY :: Effect

foreign import showError :: forall eff. String -> Eff (notify :: NOTIFY | eff) Unit

foreign import showInfo :: forall eff. String -> Eff (notify :: NOTIFY | eff) Unit

foreign import showWarning :: forall eff. String -> Eff (notify :: NOTIFY | eff) Unit