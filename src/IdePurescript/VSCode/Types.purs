module IdePurescript.VSCode.Types where

import Control.Monad.Aff (Aff)
import Control.Monad.Aff.AVar (AVAR)
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Class (liftEff)
import Control.Monad.Eff.Console (CONSOLE)
import Control.Monad.Eff.Exception (EXCEPTION)
import Control.Monad.Eff.Ref (REF)
import Node.Buffer (BUFFER)
import Node.ChildProcess (CHILD_PROCESS)
import Node.FS (FS)
import Node.Process (PROCESS)
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
