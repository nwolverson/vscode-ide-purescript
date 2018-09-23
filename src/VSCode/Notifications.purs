module VSCode.Notifications where

import Prelude

import Effect (Effect)

foreign import data OutputChannel :: Type

foreign import createOutputChannel :: String -> Effect OutputChannel

foreign import appendOutput :: OutputChannel -> String -> Effect Unit

foreign import appendOutputLine :: OutputChannel -> String -> Effect Unit

foreign import clearOutput :: OutputChannel -> Effect Unit

foreign import showError :: String -> Effect Unit

foreign import showInfo :: String -> Effect Unit

foreign import showWarning :: String -> Effect Unit