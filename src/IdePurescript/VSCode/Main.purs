module IdePurescript.VSCode.Main where

import Prelude

import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Uncurried (EffFn1, mkEffFn1)
import IdePurescript.VSCode.Assist (addClause, caseSplit)
import IdePurescript.VSCode.Imports (addIdentImport)
import IdePurescript.VSCode.Pursuit (searchPursuit, searchPursuitModules)
import IdePurescript.VSCode.Types (MainEff)
import VSCode.Command (register)
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


main :: forall eff. EffFn1 (MainEff eff) LanguageClient Unit
main = mkEffFn1 initialise
  where 
    cmd s f = register ("purescript." <> s) (\_ -> f)
    initialise client = do
      -- cmd "addImport" $ withPort $ addModuleImportCmd modulesState
      cmd "addExplicitImport" $ addIdentImport client
      cmd "caseSplit" $ caseSplit
      cmd "addClause" $ addClause

      onNotification0 client "textDocument/diagnosticsBegin" $ showStatus Building
      onNotification0 client "textDocument/diagnosticsEnd" $ showStatus BuildSuccess

      cmd "searchPursuit" $ searchPursuit
      cmd "searchPursuitModules" $ searchPursuitModules

