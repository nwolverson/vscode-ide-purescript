module VSCode.Workspace where

import Control.Monad.Eff (Eff)
import Data.Foreign


foreign import data Configuration :: *

foreign import data WORKSPACE :: !

foreign import getConfiguration :: forall eff. String -> Eff (workspace :: WORKSPACE | eff) Configuration

foreign import getValue :: forall eff. Configuration -> String -> Eff (workspace :: WORKSPACE | eff) Foreign

foreign import rootPath :: forall eff. Eff (workspace :: WORKSPACE | eff) String