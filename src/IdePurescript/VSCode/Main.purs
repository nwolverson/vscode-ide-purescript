module IdePurescript.VSCode.Main where

import Prelude

import Data.Tuple (Tuple(..))
import Effect (Effect)
import Effect.Uncurried (EffectFn1, EffectFn2, mkEffectFn1, mkEffectFn2)
import Foreign (Foreign)
import Foreign.Object (Object)
import Foreign.Object as Object
import IdePurescript.VSCode.Assist (addClause, caseSplit, typedHole)
import IdePurescript.VSCode.Imports (addIdentImport, addModuleImport)
import IdePurescript.VSCode.Pursuit (searchPursuit, searchPursuitModules)
import IdePurescript.VSCode.Types (Notifications)
import VSCode.LanguageClient (LanguageClient, onNotification0)
import VSCode.Window (setStatusBarMessage)

data Status = Building | BuildFailure | BuildErrors | BuildSuccess | Cleaning | CleanSuccess | CleanFailure

showStatus :: Status -> Effect Unit
showStatus status = do
  let icon = case status of
              Building -> "$(beaker)"
              BuildFailure -> "$(bug)"
              BuildErrors -> "$(check)"
              BuildSuccess -> "$(check)"
              Cleaning -> "$(beaker)"
              CleanSuccess -> "$(check)"
              CleanFailure -> "$(bug)"
  setStatusBarMessage $ icon <> " PureScript"

main :: EffectFn2 Notifications LanguageClient (Object (EffectFn1 (Array Foreign) Unit))
main = mkEffectFn2 initialise
  where 
    cmdA s f = Tuple ("purescript." <> s) $ mkEffectFn1 f
    cmd s f = cmdA s (\_ -> f)
    initialise notifications client = do
      onNotification0 client "textDocument/diagnosticsBegin" $ showStatus Building *> notifications.diagnosticsBegin
      onNotification0 client "textDocument/diagnosticsEnd" $ showStatus BuildSuccess *> notifications.diagnosticsEnd
      onNotification0 client "textDocument/cleanBegin" $ showStatus Cleaning *> notifications.cleanBegin
      onNotification0 client "textDocument/cleanEnd" $ showStatus CleanSuccess *> notifications.cleanEnd

      pure $ Object.fromFoldable
        [ cmd "addExplicitImport" $ addIdentImport client
        , cmd "addImport" $ addModuleImport client
        , cmd "caseSplit" $ caseSplit
        , cmd "addClause" $ addClause
        , cmdA "typedHole" $ typedHole
        , cmd "searchPursuit" $ searchPursuit
        , cmd "searchPursuitModules" $ searchPursuitModules
        ]
