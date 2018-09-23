module VSCode.TextEditor (TextEditor, setText, setTextInRange, setTextViaDiff, getDocument) where

import Prelude

import Data.Either (Either(..))
import Effect (Effect)
import Effect.Aff (Aff, makeAff, nonCanceler)
import VSCode.Range (Range)
import VSCode.TextDocument (TextDocument)
    
foreign import data TextEditor :: Type

foreign import setTextImpl :: TextEditor -> String -> (Boolean -> Effect Unit) -> Effect Unit

-- | Replace the entire editor text in one edit operation
setText :: TextEditor -> String -> Aff Boolean
setText ed s = makeAff $ \cb -> setTextImpl ed s (cb <<< Right) $> nonCanceler

foreign import setTextViaDiffImpl :: TextEditor -> String -> (Boolean -> Effect Unit) -> Effect Unit

-- | Replace the entire editor text where it has changed in the middle as an edit just of that middle part. Assumes a single changed region. 
setTextViaDiff :: TextEditor -> String -> Aff Boolean
setTextViaDiff ed s = makeAff $ \cb -> setTextViaDiffImpl ed s (cb <<< Right) $> nonCanceler


foreign import setTextInRangeImpl :: TextEditor -> String -> Range -> (Boolean -> Effect Unit) -> Effect Unit

-- | Replace the editor text in a given range with the supplied text
setTextInRange :: TextEditor -> String -> Range -> Aff Boolean
setTextInRange ed s range = makeAff $ \cb -> setTextInRangeImpl ed s range (cb <<< Right) $> nonCanceler

foreign import getDocument :: TextEditor -> TextDocument