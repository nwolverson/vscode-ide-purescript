module VSCode.TextEditor where

import Prelude
import VSCode.TextDocument (TextDocument, EDITOR)
import VSCode.Range (Range)
import Control.Monad.Eff (Eff)
import Control.Monad.Aff (Aff, makeAff)
    
foreign import data TextEditor :: *

foreign import setTextImpl :: forall eff. TextEditor -> String -> (Boolean -> Eff (editor :: EDITOR | eff) Unit) -> Eff (editor :: EDITOR | eff) Unit

setText :: forall eff. TextEditor -> String -> Aff (editor :: EDITOR | eff) Boolean
setText ed s = makeAff $ \_ succ -> setTextImpl ed s succ

foreign import setTextInRangeImpl :: forall eff. TextEditor -> String -> Range -> (Boolean -> Eff (editor :: EDITOR | eff) Unit) -> Eff (editor :: EDITOR | eff) Unit

setTextInRange :: forall eff. TextEditor -> String -> Range -> Aff (editor :: EDITOR | eff) Boolean
setTextInRange ed s range = makeAff $ \_ succ -> setTextInRangeImpl ed s range succ

foreign import getDocument :: TextEditor -> TextDocument