module Main where


import Prelude

import Effect.Uncurried (EffectFn1)
import Foreign (Foreign)
import Foreign.Object (Object)
import IdePurescript.VSCode.Main (main) as M
import VSCode.LanguageClient (LanguageClient)

main :: EffectFn1 LanguageClient (Object (EffectFn1 (Array Foreign) Unit))
main = M.main
