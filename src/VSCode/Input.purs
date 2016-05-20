module VSCode.Input (DIALOG, InputBoxOptions, defaultInputOptions, getInput, showQuickPick) where

import Prelude
import Control.Monad.Aff (Aff, makeAff)
import Control.Monad.Eff (Eff)
import Data.Maybe (Maybe(..))
import Data.Nullable (Nullable, toNullable)

type InputBoxOptions = {
    prompt:: Nullable String
  , value:: Nullable String
  , placeHolder:: Nullable String
  , validateInput:: Nullable (String -> Nullable String)
}

foreign import data DIALOG :: !

foreign import showInputBox :: forall eff. InputBoxOptions -> (String -> Eff (dialog :: DIALOG | eff) Unit) -> Eff (dialog :: DIALOG | eff) Unit

getInput :: forall eff. InputBoxOptions -> Aff (dialog :: DIALOG | eff) String
getInput opts = makeAff $ \_ succ -> showInputBox opts succ

defaultInputOptions :: InputBoxOptions
defaultInputOptions =
    {
      prompt: toNullable Nothing
    , value: toNullable Nothing
    , placeHolder: toNullable Nothing
    , validateInput: toNullable Nothing
    }

foreign import showQuickPickImpl :: forall eff. Array String -> Maybe String -> (String -> Maybe String) -> (Maybe String -> Eff (dialog :: DIALOG | eff) Unit) -> Eff (dialog :: DIALOG | eff) Unit

showQuickPick :: forall eff. Array String -> Aff (dialog :: DIALOG | eff) (Maybe String)
showQuickPick items = makeAff $ \_ succ -> showQuickPickImpl items Nothing Just succ 