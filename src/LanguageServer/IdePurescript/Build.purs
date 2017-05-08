module LanguageServer.IdePurescript.Build where

import Prelude
import Control.Monad.Aff (Aff)
import Control.Monad.Eff.Class (liftEff)
import Data.Array (filter, notElem)
import Data.Maybe (Maybe(..), maybe)
import Data.Nullable (toNullable)
import IdePurescript.Build (rebuild)
import IdePurescript.PscErrors (PscError(..))
import IdePurescript.PscErrors as PscErrors
import LanguageServer.IdePurescript.Config (censorCodes)
import LanguageServer.IdePurescript.Types (ServerState(..), MainEff)
import LanguageServer.Types (Diagnostic(Diagnostic), DocumentUri, Position(Position), Range(Range), Settings)
import LanguageServer.Uri (uriToFilename)

positionToRange :: PscErrors.Position -> Range
positionToRange ({ startLine, startColumn, endLine, endColumn}) =
  Range { start: Position { line: startLine-1, character: startColumn-1 }
        , end:   Position { line: endLine-1, character: endColumn-1 } }

getDiagnostics :: forall eff. DocumentUri -> Settings -> ServerState (MainEff eff) -> Aff (MainEff eff)
  ({ pscErrors :: Array PscError, diagnostics :: Array Diagnostic })
getDiagnostics uri settings state = do 
  filename <- liftEff $ uriToFilename uri
  case state of
    ServerState { port: Just port } -> do
      -- TODO: Status Indication
      { errors: { warnings, errors }, success } <- rebuild port filename
      let warnings' = censorWarnings warnings
      pure $ { diagnostics: (convertDiagnostic true <$> errors) <> (convertDiagnostic false <$> warnings)
             , pscErrors: errors <> warnings' }

    _ -> pure { pscErrors: [], diagnostics: [] }

  where
    dummyRange = 
      Range { start: Position { line: 1, character: 1 }
            , end:   Position { line: 1, character: 1 } }
    convertDiagnostic isError (PscError { errorCode, position, message }) = 
      Diagnostic
        { range: maybe dummyRange positionToRange position
        , severity: toNullable $ Just $ if isError then 1 else 2 
        , code: toNullable $ Just $ errorCode
        , source: toNullable $ Just "PureScript"
        , message
        }

    censorWarnings :: Array PscError -> Array PscError
    censorWarnings = filter (flip notElem codes <<< getCode)
      where
        getCode (PscError { errorCode }) = errorCode
        codes = censorCodes settings
      
