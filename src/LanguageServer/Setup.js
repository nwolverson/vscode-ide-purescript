"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
var vscode_languageserver_1 = require("vscode-languageserver");
exports.initConnection = function (cb) { return function () {
    var conn = vscode_languageserver_1.createConnection(new vscode_languageserver_1.IPCMessageReader(process), new vscode_languageserver_1.IPCMessageWriter(process));
    conn.listen();
    conn.onInitialize(function (params) {
        conn.console.info(JSON.stringify(params));
        cb({
            params: params,
            conn: conn
        })();
        return {
            capabilities: {
                // Tell the client that the server works in FULL text document sync mode
                textDocumentSync: vscode_languageserver_1.TextDocumentSyncKind.Full,
                // Tell the client that the server support code complete
                completionProvider: true,
                hoverProvider: true,
                definitionProvider: true,
                workspaceSymbolProvider: true,
                documentSymbolProvider: true,
                codeActionProvider: true,
                executeCommandProvider: {
                    commands: ["purescript:test"]
                }
            }
        };
    });
    conn.onDidChangeConfiguration(function (params) {
        console.log(params.settings);
        conn.onRequest;
    });
    conn.onExecuteCommand(function () {
        conn.console.log("Command!");
    });
    return conn;
}; };
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
exports.initDocumentStore = function (conn) { return function () {
    var documents = new vscode_languageserver_1.TextDocuments();
    documents.listen(conn);
    return documents;
}; };
