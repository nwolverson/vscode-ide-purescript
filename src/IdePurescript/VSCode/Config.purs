module IdePurescript.VSCode.Config where

import Prelude

import Control.Monad.Except (runExcept)
import Data.Either (either)
import Data.Traversable (traverse)
import Effect (Effect)
import Foreign (F, Foreign, readArray, readBoolean, readInt, readString)
import VSCode.Workspace (getConfiguration, getValue)

getConfig :: forall a. (Foreign -> F a) -> String -> a -> Effect a
getConfig readValue key default = do 
    config <- getConfiguration "purescript"
    either (const default) identity <<< runExcept <<< readValue <$> getValue config key

getBoolean :: String -> Boolean -> Effect Boolean
getBoolean = getConfig readBoolean


getString :: String -> String -> Effect String
getString = getConfig readString

getInt :: String -> Int -> Effect Int
getInt = getConfig readInt

serverExe :: Effect String
serverExe = getString "pscIdeServerExe" "psc-ide-server"

pursExe :: Effect String
pursExe = getString "pursExe" "purs"

pscIdePort :: Effect Int
pscIdePort = getInt "pscIdePort" 4242

autoCompleteAllModules :: Effect Boolean
autoCompleteAllModules = getBoolean "autocompleteAllModules" true 

addNpmPath :: Effect Boolean
addNpmPath = getBoolean "addNpmPath" false

usePurs :: Effect Boolean
usePurs = getBoolean "useCombinedExe" true

packagePath :: Effect String
packagePath = getString "packagePath" "bower_components"

censorCodes :: Effect (Array String)
censorCodes = getConfig (readArray >=> traverse readString) "censorWarnings" []

autoStartPscIde :: Effect Boolean
autoStartPscIde = getBoolean "autoStartPscIde" true

autocompleteAddImport :: Effect Boolean
autocompleteAddImport = getBoolean "autocompleteAddImport" true
