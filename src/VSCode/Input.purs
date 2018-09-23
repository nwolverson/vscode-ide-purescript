module VSCode.Input (InputBoxOptions, defaultInputOptions, getInput, showQuickPick, showQuickPickItems, QuickPickItem, showQuickPickItemsOpt) where

import Prelude

import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Data.Nullable (Nullable, toNullable)
import Effect (Effect)
import Effect.Aff (Aff, makeAff, nonCanceler)

type InputBoxOptions = {
    prompt:: Nullable String
  , value:: Nullable String
  , placeHolder:: Nullable String
  , validateInput:: Nullable (String -> Nullable String)
}

foreign import showInputBox :: InputBoxOptions -> (String -> Effect Unit) -> Effect Unit

getInput :: InputBoxOptions -> Aff String
getInput opts = makeAff $ \cb -> showInputBox opts (cb <<< Right) $> nonCanceler

defaultInputOptions :: InputBoxOptions
defaultInputOptions =
    {
      prompt: toNullable Nothing
    , value: toNullable Nothing
    , placeHolder: toNullable Nothing
    , validateInput: toNullable Nothing
    }

foreign import showQuickPickImpl :: Array String -> Maybe String -> (String -> Maybe String) -> (Maybe String -> Effect Unit) -> Effect Unit

foreign import showQuickPickItemsImpl :: Array QuickPickItem -> Maybe QuickPickItem -> (QuickPickItem -> Maybe QuickPickItem) -> (Maybe QuickPickItem -> Effect Unit) -> Effect Unit

foreign import showQuickPickItemsOptImpl :: Array QuickPickItem -> QuickPickOptions -> Maybe QuickPickItem -> (QuickPickItem -> Maybe QuickPickItem) -> (Maybe QuickPickItem -> Effect Unit) -> Effect Unit

type QuickPickOptions = {
  placeHolder :: Nullable String
}

type QuickPickItem = {
  description :: String,
  detail :: String,
  label :: String
}

showQuickPick :: Array String -> Aff (Maybe String)
showQuickPick items = makeAff $ \cb -> showQuickPickImpl items Nothing Just (cb <<< Right) $> nonCanceler 

showQuickPickItems :: Array QuickPickItem -> Aff (Maybe QuickPickItem)
showQuickPickItems items = makeAff $ \cb -> showQuickPickItemsImpl items Nothing Just (cb <<< Right) $> nonCanceler 

showQuickPickItemsOpt :: Array QuickPickItem -> QuickPickOptions -> Aff (Maybe QuickPickItem)
showQuickPickItemsOpt items opt = makeAff $ \cb -> showQuickPickItemsOptImpl items opt Nothing Just (cb <<< Right) $> nonCanceler 