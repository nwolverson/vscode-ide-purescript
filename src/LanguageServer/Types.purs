module LanguageServer.Types where

import Prelude
import Control.Monad.Eff (kind Effect)
import Data.Foreign (Foreign)
import Data.Maybe (Maybe(..))
import Data.Newtype (class Newtype, over)
import Data.Nullable (Nullable, toNullable)

foreign import data CONN :: Effect
foreign import data Connection :: Type
foreign import data DocumentStore :: Type

derive instance newtypeDocumentUri :: Newtype DocumentUri _

newtype DocumentUri = DocumentUri String

newtype Position = Position { line :: Int, character :: Int }

derive instance newtypePosition :: Newtype Position _

newtype Range = Range { start :: Position, end :: Position }

derive instance newtypeRange :: Newtype Range _

newtype Location = Location { uri :: DocumentUri, range :: Range }

derive instance newtypeLocation :: Newtype Location _

newtype Diagnostic = Diagnostic
    { range :: Range
    , severity :: Nullable Int -- 1 (Error) - 4 (Hint)
    , code :: Nullable String -- String | Int
    , source :: Nullable String
    , message :: String
    }
derive instance newtypeDiagnostic :: Newtype Diagnostic _

newtype CompletionItem = CompletionItem
    { label :: String
    , kind :: Nullable Int
    , detail :: Nullable String
    , documentation :: Nullable String
    , sortText :: Nullable String
    , filterText :: Nullable String
    , insertText :: Nullable String
    , textEdit :: Nullable TextEdit
    , additionalTextEdits :: Nullable (Array TextEdit)
    , command :: Nullable Command
    }

derive instance newtypeCompletionItem :: Newtype CompletionItem _

data CompletionItemKind
	= Text
	| Method
	| Function
	| Constructor
	| Field
	| Variable
	| Class
	| Interface
	| Module
	| Property
	| Unit
	| Value
	| Enum
	| Keyword
	| Snippet
	| Color
	| File
	| Reference


defaultCompletionItem :: String -> CompletionItem
defaultCompletionItem label = CompletionItem
    { label
    , kind: toNullable Nothing
    , detail: toNullable Nothing
    , documentation: toNullable Nothing
    , sortText: toNullable Nothing
    , filterText: toNullable Nothing
    , insertText: toNullable Nothing
    , textEdit: toNullable Nothing
    , additionalTextEdits: toNullable Nothing
    , command: toNullable Nothing
    }

completionItem :: String -> CompletionItemKind -> CompletionItem
completionItem label k = defaultCompletionItem label # over CompletionItem ( _ { kind = toNullable $ Just $ completionItemKindToInt k } )

completionItemKindToInt :: CompletionItemKind -> Int
completionItemKindToInt = case _ of
    Text -> 1
    Method -> 2
    Function -> 3
    Constructor -> 4
    Field -> 5
    Variable -> 6
    Class -> 7
    Interface -> 8
    Module -> 9
    Property -> 10
    Unit -> 11
    Value -> 12
    Enum -> 13
    Keyword -> 14
    Snippet -> 15
    Color -> 16
    File -> 17
    Reference -> 18

newtype SymbolInformation = SymbolInformation
    { name :: String
    , kind :: Number
    , location :: Location
    , containerName :: Nullable String
    }

newtype Hover = Hover { contents :: String, range :: Nullable Range }

newtype Command = Command { title :: String, command :: String, arguments :: Nullable (Array Foreign) }

newtype TextEdit = TextEdit { range :: Range, newText :: String }

-- newtype TextDocumentEdit = TextDocumentEdit { textDocument :: , edits :: Array TextEdit }

newtype TextDocumentIdentifier = TextDocumentIdentifier { uri :: DocumentUri }

derive instance newtypeTextDocumentIdentifier :: Newtype TextDocumentIdentifier _


type Settings = Foreign

