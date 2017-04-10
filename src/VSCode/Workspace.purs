module VSCode.Workspace where

import Control.Monad.Eff (Eff, kind Effect)
import Data.Foreign

foreign import data Configuration :: Type

foreign import data WORKSPACE :: Effect

foreign import getConfiguration :: forall eff. String -> Eff (workspace :: WORKSPACE | eff) Configuration

foreign import getValue :: forall eff. Configuration -> String -> Eff (workspace :: WORKSPACE | eff) Foreign

foreign import rootPath :: forall eff. Eff (workspace :: WORKSPACE | eff) String