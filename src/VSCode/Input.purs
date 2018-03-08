module VSCode.Input (DIALOG, InputBoxOptions, defaultInputOptions, getInput, showQuickPick, showQuickPickItems, QuickPickItem, showQuickPickItemsOpt) where

import Prelude
import Control.Monad.Aff (Aff, makeAff)
import Control.Monad.Eff (Eff, kind Effect)
import Data.Maybe (Maybe(..))
import Data.Nullable (Nullable, toNullable)

type InputBoxOptions = {
    prompt:: Nullable String
  , value:: Nullable String
  , placeHolder:: Nullable String
  , validateInput:: Nullable (String -> Nullable String)
}

foreign import data DIALOG :: Effect

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

foreign import showQuickPickItemsImpl :: forall eff. Array QuickPickItem -> Maybe QuickPickItem -> (QuickPickItem -> Maybe QuickPickItem) -> (Maybe QuickPickItem -> Eff (dialog :: DIALOG | eff) Unit) -> Eff (dialog :: DIALOG | eff) Unit

foreign import showQuickPickItemsOptImpl :: forall eff. Array QuickPickItem -> QuickPickOptions -> Maybe QuickPickItem -> (QuickPickItem -> Maybe QuickPickItem) -> (Maybe QuickPickItem -> Eff (dialog :: DIALOG | eff) Unit) -> Eff (dialog :: DIALOG | eff) Unit

type QuickPickOptions = {
  placeHolder :: Nullable String
}

type QuickPickItem = {
  description :: String,
  detail :: String,
  label :: String
}

showQuickPick :: forall eff. Array String -> Aff (dialog :: DIALOG | eff) (Maybe String)
showQuickPick items = makeAff $ \_ succ -> showQuickPickImpl items Nothing Just succ 

showQuickPickItems :: forall eff. Array QuickPickItem -> Aff (dialog :: DIALOG | eff) (Maybe QuickPickItem)
showQuickPickItems items = makeAff $ \_ succ -> showQuickPickItemsImpl items Nothing Just succ 

showQuickPickItemsOpt :: forall eff. Array QuickPickItem -> QuickPickOptions -> Aff (dialog :: DIALOG | eff) (Maybe QuickPickItem)
showQuickPickItemsOpt items opt = makeAff $ \_ succ -> showQuickPickItemsOptImpl items opt Nothing Just succ 