module IdePurescript.VSCode.Types where

import Control.Monad.Aff (runAff, Aff)
import Control.Monad.Aff.AVar (AVAR)
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Class (liftEff)
import Control.Monad.Eff.Console (CONSOLE)
import Control.Monad.Eff.Ref (REF)
import Node.Buffer (BUFFER)
import Node.ChildProcess (CHILD_PROCESS)
import Node.FS (FS)
import Node.Process (PROCESS)
import Prelude (unit, pure, const, ($))
import PscIde (NET)
import VSCode.Command (COMMAND)
import VSCode.Input (DIALOG)
import VSCode.Notifications (NOTIFY)
import VSCode.Window (EDITOR)

type MainEff a =
  ( buffer :: BUFFER
  , fs :: FS
  , console :: CONSOLE
  , net :: NET
  , ref :: REF
  , avar :: AVAR
  , cp :: CHILD_PROCESS
  , notify :: NOTIFY
  , process :: PROCESS
  , command :: COMMAND
  , dialog :: DIALOG
  , editor :: EDITOR
  | a
  )

liftEffM :: forall a eff. Eff (MainEff eff) a -> Aff (MainEff eff) a
liftEffM = liftEff

launchAffSilent = runAff (const $ pure unit) (const $ pure unit)

launchAffAndRaise = launchAffSilent
