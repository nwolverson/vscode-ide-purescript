module VSCode.Diagnostic where

import VSCode.Range

foreign import data Diagnostic :: *

type Severity = Int

foreign import mkDiagnostic :: Range -> String -> Severity ->  Diagnostic
foreign import mkDiagnosticWithInfo :: forall a. Range -> String -> Severity -> a -> Diagnostic
