module IdePurescript.VSCode.Types where

import Prelude

import Effect (Effect)
import Effect.Aff (Aff, runAff)

launchAffSilent :: forall a. Aff a -> Effect Unit
launchAffSilent = void <<< (runAff (const $ pure unit))

-- Uhh... Why was this the same again?
launchAffAndRaise :: forall a. Aff a -> Effect Unit
launchAffAndRaise = launchAffSilent

type Notifications =
  { diagnosticsBegin :: Effect Unit
  , diagnosticsEnd :: Effect Unit
  , cleanBegin :: Effect Unit
  , cleanEnd :: Effect Unit
  }
