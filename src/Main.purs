module Main where

import Prelude
import Control.Monad.Eff.Uncurried (EffFn1)
import IdePurescript.VSCode.Main (main) as M
import IdePurescript.VSCode.Types (MainEff)
import VSCode.LanguageClient (LanguageClient)

main :: forall eff. EffFn1 (MainEff eff) LanguageClient Unit
main = M.main
