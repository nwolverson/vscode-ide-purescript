module Main where

import Prelude
import Control.Monad.Eff (Eff)
import Data.Foreign (Foreign, toForeign)
import IdePurescript.VSCode.Main (main) as M
import IdePurescript.VSCode.Types (MainEff)

main :: forall eff. Eff (MainEff eff) Foreign
main = toForeign <$> M.main
