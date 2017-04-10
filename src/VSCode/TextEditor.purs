module VSCode.TextEditor (TextEditor, setText, setTextInRange, setTextViaDiff, getDocument) where

import Prelude
import VSCode.TextDocument (TextDocument, EDITOR)
import VSCode.Range (Range)
import Control.Monad.Eff (Eff, kind Effect)
import Control.Monad.Aff (Aff, makeAff)
    
foreign import data TextEditor :: Type

foreign import setTextImpl :: forall eff. TextEditor -> String -> (Boolean -> Eff (editor :: EDITOR | eff) Unit) -> Eff (editor :: EDITOR | eff) Unit

-- | Replace the entire editor text in one edit operation
setText :: forall eff. TextEditor -> String -> Aff (editor :: EDITOR | eff) Boolean
setText ed s = makeAff $ \_ succ -> setTextImpl ed s succ

foreign import setTextViaDiffImpl :: forall eff. TextEditor -> String -> (Boolean -> Eff (editor :: EDITOR | eff) Unit) -> Eff (editor :: EDITOR | eff) Unit

-- | Replace the entire editor text where it has changed in the middle as an edit just of that middle part. Assumes a single changed region. 
setTextViaDiff :: forall eff. TextEditor -> String -> Aff (editor :: EDITOR | eff) Boolean
setTextViaDiff ed s = makeAff $ \_ succ -> setTextViaDiffImpl ed s succ


foreign import setTextInRangeImpl :: forall eff. TextEditor -> String -> Range -> (Boolean -> Eff (editor :: EDITOR | eff) Unit) -> Eff (editor :: EDITOR | eff) Unit

-- | Replace the editor text in a given range with the supplied text
setTextInRange :: forall eff. TextEditor -> String -> Range -> Aff (editor :: EDITOR | eff) Boolean
setTextInRange ed s range = makeAff $ \_ succ -> setTextInRangeImpl ed s range succ

foreign import getDocument :: TextEditor -> TextDocument