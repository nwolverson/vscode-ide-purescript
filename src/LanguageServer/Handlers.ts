import { RequestHandler, IConnection, createConnection, IPCMessageReader, IPCMessageWriter, TextDocuments,Location,  DefinitionRequest, TextDocumentPositionParams, CompletionItem, Hover, DocumentSymbolParams, PublishDiagnosticsParams, WorkspaceEdit } from 'vscode-languageserver';

let registerHandler = <T1,T2>(registerF: (handler: RequestHandler<T1, T2, void>) => void) =>
    (f: (args: T1) => () => T2) => () => registerF(x => f(x)());

export const onDefinition = (conn: IConnection) => registerHandler(conn.onDefinition);

export const onCompletion = (conn: IConnection) => registerHandler(conn.onCompletion);

export const onHover = (conn: IConnection) => registerHandler(conn.onHover);

export const onDocumentSymbol = (conn: IConnection) => registerHandler(conn.onDocumentSymbol);

export const onWorkspaceSymbol = (conn: IConnection) => registerHandler(conn.onWorkspaceSymbol);

export const onCodeAction = (conn: IConnection) => registerHandler(conn.onCodeAction);

export const onDidChangeConfiguration = (conn: IConnection) => registerHandler(conn.onDidChangeConfiguration);

export const publishDiagnostics = (conn: IConnection) => (params: PublishDiagnosticsParams) => () => conn.sendDiagnostics(params);

export const applyEdit = (conn: IConnection) => (edit: WorkspaceEdit) => () => conn.workspace.applyEdit(edit);

export const onExecuteCommand = (conn: IConnection) => registerHandler(conn.onExecuteCommand);

