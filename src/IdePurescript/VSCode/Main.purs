module IdePurescript.VSCode.Main where

import Prelude

import Data.Tuple (Tuple(..))
import Effect (Effect)
import Effect.Uncurried (EffectFn1, mkEffectFn1)
import Foreign (Foreign)
import Foreign.Object (Object)
import Foreign.Object as Object
import IdePurescript.VSCode.Assist (addClause, caseSplit, fixTypo, typedHole)
import IdePurescript.VSCode.Imports (addIdentImport, addModuleImport)
import IdePurescript.VSCode.Pursuit (searchPursuit, searchPursuitModules)
import VSCode.LanguageClient (LanguageClient, onNotification0)
import VSCode.Window (setStatusBarMessage)

data Status = Building | BuildFailure | BuildErrors | BuildSuccess

showStatus :: Status -> Effect Unit
showStatus status = do
  let icon = case status of
              Building -> "$(beaker)"
              BuildFailure -> "$(bug)"
              BuildErrors -> "$(check)"
              BuildSuccess -> "$(check)"
  setStatusBarMessage $ icon <> " PureScript"

main :: EffectFn1 LanguageClient (Object (EffectFn1 (Array Foreign) Unit))
main = mkEffectFn1 initialise
  where 
    cmdA s f = Tuple ("purescript." <> s) $ mkEffectFn1 f
    cmd s f = cmdA s (\_ -> f)
    initialise client = do
      onNotification0 client "textDocument/diagnosticsBegin" $ showStatus Building
      onNotification0 client "textDocument/diagnosticsEnd" $ showStatus BuildSuccess

      pure $ Object.fromFoldable
        [ cmd "addExplicitImport" $ addIdentImport client
        , cmd "addImport" $ addModuleImport client
        , cmd "caseSplit" $ caseSplit
        , cmd "addClause" $ addClause
        , cmdA "typedHole" $ typedHole
        , cmd "searchPursuit" $ searchPursuit
        , cmd "searchPursuitModules" $ searchPursuitModules
        , cmdA "fixTypo" $ fixTypo client
        ]
