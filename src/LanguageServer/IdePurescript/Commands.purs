module LanguageServer.IdePurescript.Commands where

import Prelude
import Data.Foreign (Foreign, toForeign)
import Data.Maybe (Maybe(..))
import Data.Nullable (toNullable)
import LanguageServer.Types (Command(..), DocumentUri)

cmdName :: CommandInfo -> String
cmdName (CommandInfo _ command) = "purescript:" <> command

c :: CommandInfo -> Maybe (Array Foreign) -> Command
c cmd@(CommandInfo title command) args = Command { title, command: cmdName cmd, arguments: toNullable args }

data CommandInfo = CommandInfo String String

caseSplitCmd :: CommandInfo
caseSplitCmd = CommandInfo "Case split (explicit position)" "caseSplit-explicit"

addClauseCmd :: CommandInfo
addClauseCmd = CommandInfo "Add clause (explicit position/cmd)" "addClause-explicit"

addCompletionImportCmd :: CommandInfo
addCompletionImportCmd = CommandInfo "Add completion import" "addCompletionImport"

addCompletionImport :: String -> Maybe String -> DocumentUri -> Command
addCompletionImport ident mod uri = c addCompletionImportCmd $
  Just [ toForeign ident, toForeign $ toNullable mod, toForeign uri ]

commands :: Array String
commands = cmdName <$> 
  [ addCompletionImportCmd 
  , caseSplitCmd
  , addClauseCmd
  ]

