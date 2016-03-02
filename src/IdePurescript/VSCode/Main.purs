module IdePurescript.VSCode.Main where

import Prelude
import Control.Monad.Eff
import Control.Monad.Eff.Console

main :: forall eff. Eff (console :: CONSOLE | eff) { build :: Eff (console :: CONSOLE | eff) Unit } 
main = pure {
    build: log "Build called!"
}