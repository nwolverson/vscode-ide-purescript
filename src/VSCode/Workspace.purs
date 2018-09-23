module VSCode.Workspace where

import Effect (Effect)
import Foreign (Foreign)

foreign import data Configuration :: Type

foreign import getConfiguration :: String -> Effect Configuration

foreign import getValue :: Configuration -> String -> Effect Foreign

foreign import rootPath :: Effect String