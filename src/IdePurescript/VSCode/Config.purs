module IdePurescript.VSCode.Config where

import Prelude
import Control.Monad.Eff (Eff)
import Control.Monad.Except (runExcept)
import Data.Either (either)
import Data.Foreign (F, Foreign, readArray, readBoolean, readInt, readString)
import Data.Traversable (traverse)
import VSCode.Workspace (WORKSPACE, getConfiguration, getValue)

getConfig :: forall a eff. (Foreign -> F a) -> String -> a -> Eff (workspace :: WORKSPACE | eff ) a
getConfig readValue key default = do 
    config <- getConfiguration "purescript"
    either (const default) id <<< runExcept <<< readValue <$> getValue config key

getBoolean :: forall eff. String -> Boolean -> Eff (workspace :: WORKSPACE | eff ) Boolean
getBoolean = getConfig readBoolean


getString :: forall eff. String -> String -> Eff (workspace :: WORKSPACE | eff ) String
getString = getConfig readString

getInt :: forall eff. String -> Int -> Eff (workspace :: WORKSPACE | eff ) Int
getInt = getConfig readInt

type ConfigEff eff = Eff ( workspace :: WORKSPACE | eff )

serverExe :: forall eff. ConfigEff eff String
serverExe = getString "pscIdeServerExe" "psc-ide-server"

pursExe :: forall eff. ConfigEff eff String
pursExe = getString "pursExe" "purs"

pscIdePort :: forall eff. ConfigEff eff Int
pscIdePort = getInt "pscIdePort" 4242

autoCompleteAllModules :: forall eff. ConfigEff eff Boolean
autoCompleteAllModules = getBoolean "autocompleteAllModules" true 

addNpmPath :: forall eff. ConfigEff eff Boolean
addNpmPath = getBoolean "addNpmPath" false

usePurs :: forall eff. ConfigEff eff Boolean
usePurs = getBoolean "useCombinedExe" true

packagePath :: forall eff. ConfigEff eff String
packagePath = getString "packagePath" "bower_components"

censorCodes :: forall eff. ConfigEff eff (Array String)
censorCodes = getConfig (readArray >=> traverse readString) "censorWarnings" []

autoStartPscIde :: forall eff. ConfigEff eff Boolean
autoStartPscIde = getBoolean "autoStartPscIde" true

autocompleteAddImport :: forall eff. ConfigEff eff Boolean
autocompleteAddImport = getBoolean "autocompleteAddImport" true
