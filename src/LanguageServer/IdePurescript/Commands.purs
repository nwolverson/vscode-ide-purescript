module LanguageServer.IdePurescript.Commands where

import Prelude
import Data.Foreign (Foreign, toForeign)
import Data.Maybe (Maybe(..))
import Data.Nullable (toNullable)
import LanguageServer.Types (Command(..), DocumentUri(..))

cmdName :: CommandInfo -> String
cmdName (CommandInfo _ command) = "purescript:" <> command

c :: CommandInfo -> Maybe (Array Foreign) -> Command
c cmd@(CommandInfo title command) args = Command { title, command: cmdName cmd, arguments: toNullable args }

data CommandInfo = CommandInfo String String

addCompletionImportCmd :: CommandInfo
addCompletionImportCmd = CommandInfo "Add completion import" "addCompletionImport"

addCompletionImport :: String -> String -> DocumentUri -> Command
addCompletionImport ident mod uri = c addCompletionImportCmd $ Just [ toForeign ident, toForeign mod, toForeign uri ]

commands :: Array String
commands = cmdName <$> [ addCompletionImportCmd ]

