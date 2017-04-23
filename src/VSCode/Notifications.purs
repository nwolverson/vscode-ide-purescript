module VSCode.Notifications where

import Prelude (Unit)
import Control.Monad.Eff

foreign import data NOTIFY :: Effect

foreign import data OutputChannel :: Type

foreign import createOutputChannel :: forall eff. String -> Eff (notify :: NOTIFY | eff) OutputChannel

foreign import appendOutput :: forall eff. OutputChannel -> String -> Eff (notify :: NOTIFY | eff) Unit

foreign import appendOutputLine :: forall eff. OutputChannel -> String -> Eff (notify :: NOTIFY | eff) Unit

foreign import clearOutput :: forall eff. OutputChannel -> Eff (notify :: NOTIFY | eff) Unit

foreign import showError :: forall eff. String -> Eff (notify :: NOTIFY | eff) Unit

foreign import showInfo :: forall eff. String -> Eff (notify :: NOTIFY | eff) Unit

foreign import showWarning :: forall eff. String -> Eff (notify :: NOTIFY | eff) Unit