module Node.StripTags where

import Effect (Effect)

foreign import stripTags :: String -> Effect String
