module LanguageServer.DocumentStore where

import Prelude
import Control.Monad.Eff (Eff)
import LanguageServer.Types (CONN, DocumentStore, DocumentUri(..))
import LanguageServer.TextDocument (TextDocument)

foreign import getDocuments :: forall eff. DocumentStore ->  Eff (conn :: CONN | eff) (Array TextDocument)

foreign import getDocument :: forall eff. DocumentStore -> DocumentUri -> Eff (conn :: CONN | eff) TextDocument