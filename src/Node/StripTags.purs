module Node.StripTags where

import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Exception (EXCEPTION)

-- Arbitrary effect, not sure what it might do...
foreign import stripTags :: forall e. String -> Eff (exception :: EXCEPTION | e) String

