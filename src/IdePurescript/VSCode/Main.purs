module IdePurescript.VSCode.Main where

import Prelude

import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Class (liftEff)
import Control.Promise (Promise, fromAff)
import IdePurescript.VSCode.Assist (addClause, caseSplit)
import IdePurescript.VSCode.Imports (addIdentImport)
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

main :: forall eff. Eff (MainEff eff)
  { activate :: LanguageClient -> Eff (MainEff eff) (Promise Unit)
  }
main = do
  let cmd s f = register ("purescript." <> s) (\_ -> f)
  
  let initialise client = fromAff $ do
        liftEff do
          -- cmd "addImport" $ withPort $ addModuleImportCmd modulesState
          cmd "addExplicitImport" $ addIdentImport client
          cmd "caseSplit" $ caseSplit
          cmd "addClause" $ addClause

          onNotification0 client "textDocument/diagnosticsBegin" $ showStatus Building
          onNotification0 client "textDocument/diagnosticsEnd" $ showStatus BuildSuccess

          -- cmd "searchPursuit" $ withPort searchPursuit

  pure $ {
      activate: initialise
    }
