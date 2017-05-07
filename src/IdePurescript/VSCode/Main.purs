module IdePurescript.VSCode.Main where

import Prelude
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Class (liftEff)
import Control.Promise (Promise, fromAff)
import IdePurescript.VSCode.Assist (addClause, caseSplit)
import IdePurescript.VSCode.Imports (addIdentImport)
import IdePurescript.VSCode.Types (MainEff)
import VSCode.Command (register)
import VSCode.LanguageClient (LanguageClient)
import VSCode.Notifications (createOutputChannel)
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

-- build' :: forall eff. Notify (MainEff eff) -> Notify (MainEff eff) -> String -> String -> Eff (MainEff eff) (Promise VSBuildResult)
-- build' notify logCb command directory = fromAff $ do
--   liftEff $ logCb Info "Building"
--   let buildCommand = either (const []) (\reg -> (split reg <<< trim) command) (regex "\\s+" noFlags)
--   case uncons buildCommand of
--     Just { head: cmd, tail: args } -> do
--       liftEff $ logCb Info $ "Parsed build command, base command is: " <> cmd 
--       liftEff $ showStatus Building
--       useNpmDir <- liftEff $ Config.addNpmPath
--       res <- build { command: Command cmd args, directory, useNpmDir }
--       errors <- liftEff $ censorWarnings res.errors
--       liftEff $ if res.success then showStatus BuildSuccess
--                 else showStatus BuildErrors
--       pure $ { success: true, diagnostics: toDiagnostic' errors, quickBuild: false, file: "" }
--     Nothing -> do
--       liftEff $ notify Error "Error parsing PureScript build command"
--       liftEff $ showStatus BuildFailure
--       pure { success: false, diagnostics: [], quickBuild: false, file: "" }

main :: forall eff. Eff (MainEff eff)
  { activate :: LanguageClient -> Eff (MainEff eff) (Promise Unit)
  }
main = do
  output <- createOutputChannel "PureScript"

  let cmd s f = register ("purescript." <> s) (\_ -> f)
  
  let initialise client = fromAff $ do
        liftEff do
          -- cmd "addImport" $ withPort $ addModuleImportCmd modulesState
          cmd "addExplicitImport" $ addIdentImport client
          cmd "caseSplit" $ caseSplit
          cmd "addClause" $ addClause

          -- cmd "searchPursuit" $ withPort searchPursuit

  pure $ {
      activate: initialise
    }
