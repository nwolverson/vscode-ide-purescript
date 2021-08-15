module Main where


import Prelude

import Effect.Uncurried (EffectFn1, EffectFn2)
import Foreign (Foreign)
import Foreign.Object (Object)
import IdePurescript.VSCode.Main (main) as M
import IdePurescript.VSCode.Types (Notifications)
import VSCode.LanguageClient (LanguageClient)

main :: EffectFn2 Notifications LanguageClient (Object (EffectFn1 (Array Foreign) Unit))
main = M.main
