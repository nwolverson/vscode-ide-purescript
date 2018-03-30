module IdePurescript.VSCode.Main where

import Prelude

import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Uncurried (EffFn1, EffFn2, mkEffFn1)
import Data.Foreign (Foreign)
import Data.StrMap (StrMap)
import Data.StrMap as StrMap
import Data.Tuple (Tuple(..))
import IdePurescript.VSCode.Assist (addClause, caseSplit, typedHole)
import IdePurescript.VSCode.Imports (addIdentImport)
import IdePurescript.VSCode.Pursuit (searchPursuit, searchPursuitModules)
import IdePurescript.VSCode.Types (MainEff)
import VSCode.Command (COMMAND, register)
import VSCode.LanguageClient (LanguageClient, onNotification0)
import VSCode.Window (WINDOW, setStatusBarMessage)

data Status = Building | BuildFailure | BuildErrors | BuildSuccess

showStatus :: forall eff. Status -> Eff (window :: WINDOW | eff) Unit
showStatus status = do
  let icon = case status of
              Building -> "$(beaker)"
              BuildFailure -> "$(bug)"
              BuildErrors -> "$(check)"
              BuildSuccess -> "$(check)"
  setStatusBarMessage $ icon <> " PureScript"

main :: forall eff. EffFn1 (MainEff eff) LanguageClient 
  (StrMap (EffFn1 (MainEff eff) (Array Foreign) Unit))
main = mkEffFn1 initialise
  where 
    cmdA s f = Tuple ("purescript." <> s) $ mkEffFn1 f
    cmd s f = cmdA s (\_ -> f)
    initialise client = do
      onNotification0 client "textDocument/diagnosticsBegin" $ showStatus Building
      onNotification0 client "textDocument/diagnosticsEnd" $ showStatus BuildSuccess

      pure $ StrMap.fromFoldable
        [ cmd "addExplicitImport" $ addIdentImport client
        , cmd "caseSplit" $ caseSplit
        , cmd "addClause" $ addClause
        , cmdA "typedHole" $ typedHole
        , cmd "searchPursuit" $ searchPursuit
        , cmd "searchPursuitModules" $ searchPursuitModules
        ]

      -- cmd "addImport" $ withPort $ addModuleImportCmd modulesState

