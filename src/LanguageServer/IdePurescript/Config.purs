module LanguageServer.IdePurescript.Config where

import Prelude
import Control.Monad.Except (runExcept)
import Data.Either (either)
import Data.Foreign (F, Foreign, readArray, readBoolean, readInt, readString)
import Data.Foreign.Index ((!))
import Data.Traversable (traverse)

getConfig :: forall a. (Foreign -> F a) -> String -> a -> Foreign -> a
getConfig readValue key default settings = do
    either (const default) id $ runExcept val
    where
        val = do
            ps <- settings ! "purescript"
            res <- ps ! key
            readValue res

getBoolean :: String -> Boolean -> Foreign -> Boolean
getBoolean = getConfig readBoolean

getString :: String -> String -> Foreign -> String
getString = getConfig readString

getInt :: String -> Int -> Foreign -> Int
getInt = getConfig readInt

type ConfigFn a = Foreign -> a

serverExe :: ConfigFn String
serverExe = getString "pscIdeServerExe" "psc-ide-server"

pursExe :: ConfigFn String
pursExe = getString "pursExe" "purs"

pscIdePort :: ConfigFn Int
pscIdePort = getInt "pscIdePort" 4242

autoCompleteAllModules :: ConfigFn Boolean
autoCompleteAllModules = getBoolean "autocompleteAllModules" true 

addNpmPath :: ConfigFn Boolean
addNpmPath = getBoolean "addNpmPath" false

usePurs :: ConfigFn Boolean
usePurs = getBoolean "useCombinedExe" true

packagePath :: ConfigFn String
packagePath = getString "packagePath" "bower_components"

censorCodes :: ConfigFn (Array String)
censorCodes = getConfig (readArray >=> traverse readString) "censorWarnings" []

autoStartPscIde :: ConfigFn Boolean
autoStartPscIde = getBoolean "autoStartPscIde" true

autocompleteAddImport :: ConfigFn Boolean
autocompleteAddImport = getBoolean "autocompleteAddImport" true