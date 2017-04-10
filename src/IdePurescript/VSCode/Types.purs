module IdePurescript.VSCode.Types where

import Prelude
import Control.Monad.Aff (runAff, Aff)
import Control.Monad.Aff.AVar (AVAR)
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (CONSOLE)
import Control.Monad.Eff.Ref (REF)
import Node.Buffer (BUFFER)
import Node.ChildProcess (CHILD_PROCESS)
import Node.FS (FS)
import Node.Process (PROCESS)
import PscIde (NET)
import VSCode.Command (COMMAND)
import VSCode.Input (DIALOG)
import VSCode.Notifications (NOTIFY)
import VSCode.TextDocument (EDITOR)
import VSCode.Window (WINDOW)
import VSCode.Workspace (WORKSPACE)
import Control.Monad.Eff.Exception (EXCEPTION)
import Control.Monad.Eff.Random (RANDOM)

type MainEff a =
  ( exception :: EXCEPTION
  , random :: RANDOM
  , buffer :: BUFFER
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
  , window :: WINDOW
  , workspace :: WORKSPACE
  | a
  )

launchAffSilent :: forall a b. Aff a b -> Eff a Unit
launchAffSilent = void <<< (runAff (const $ pure unit) (const $ pure unit))

launchAffAndRaise :: forall a b. Aff a b -> Eff a Unit
launchAffAndRaise = launchAffSilent
