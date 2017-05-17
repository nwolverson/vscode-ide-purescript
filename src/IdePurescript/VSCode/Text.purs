module IdePurescript.VSCode.Text where

import LanguageServer.Types (DocumentUri, Range, TextDocumentEdit(..), TextDocumentIdentifier(..), TextEdit(..), WorkspaceEdit, workspaceEdit)

makeWorkspaceEdit :: DocumentUri -> Number -> Range -> String -> WorkspaceEdit
makeWorkspaceEdit uri version range newText = workspaceEdit [ edit ]
  where 
      textEdit = TextEdit { range, newText }
      docid = TextDocumentIdentifier { uri, version }
      edit = TextDocumentEdit { textDocument: docid, edits: [ textEdit ] }
      
