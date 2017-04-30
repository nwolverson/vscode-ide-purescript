import { IConnection, createConnection,InitializeParams, IPCMessageReader, IPCMessageWriter, TextDocuments, Location, Hover, TextDocumentSyncKind } from 'vscode-languageserver';

exports.initConnection = (cb: (arg: {params: InitializeParams, conn: IConnection}) => () => void) => (): IConnection => {
    const conn = createConnection(new IPCMessageReader(process), new IPCMessageWriter(process));
    conn.listen();
    
    conn.onInitialize((params) => {
        conn.console.info(JSON.stringify(params));
        cb({
            params,
            conn
        })();
        return {
            capabilities: {
                // Tell the client that the server works in FULL text document sync mode
                textDocumentSync: TextDocumentSyncKind.Full,
                // Tell the client that the server support code complete
                completionProvider: true,
                hoverProvider: true,
                definitionProvider: true,
                workspaceSymbolProvider: true,
                documentSymbolProvider: true,
                codeActionProvider: true,
                executeCommandProvider: {
                    commands: [ "purescript:test" ]
                }
            }
        };
    });
    conn.onDidChangeConfiguration((params) => {
        console.log(params.settings);
        conn.onRequest
    });
    conn.onExecuteCommand(() => {
        conn.console.log("Command!");
    })
    return conn;
}

// conn.onDefinition((params) => {
//         conn.console.log('onDefinition');
//         return Location.create('./fake-file', { start: { line: 0, character: 0}, end: { line: 1, character: 1} });
//     });
//     conn.onCompletion((params) => {
//         conn.console.log("Completion!");
//         return [
            
//         ];
//     });
//     conn.onHover((params) => {
//         conn.console.log("Hover!");
//         return {contents: "Hover!"};
//     })
//     conn.onDidChangeWatchedFiles((params) => {
//         conn.console.log("Fiel change");
//     })
//     conn.onInitialize((params) => {
//         // workspaceRoot = params.rootPath;
//         conn.console.log("Hello from server! 1");
//         conn.tracer.log("t hi 1");
//         return {
//             capabilities: {
//                 // Tell the client that the server works in FULL text document sync mode
//                 // textDocumentSync:  // documents.syncKind,
//                 // Tell the client that the server support code complete
//                 completionProvider: {
//                     resolveProvider: true
//                 },
//                 hoverProvider: true,
//                 definitionProvider: true
//             }
//         };
//     });
//     conn.console.log("Hello from server! Wednesday it is.");
//     conn.console.error("This is not an error");
//     conn.window.showInformationMessage("Hello from server!");
//     conn.tracer.log("t hi");

exports.initDocumentStore = (conn : IConnection) => () => {
    const documents: TextDocuments = new TextDocuments();
    documents.listen(conn);
    
    return documents;
}
