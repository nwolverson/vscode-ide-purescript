"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
var registerHandler = function (registerF) {
    return function (f) { return function () { return registerF(function (x) { return f(x)(); }); }; };
};
exports.onDefinition = function (conn) { return registerHandler(conn.onDefinition); };
exports.onCompletion = function (conn) { return registerHandler(conn.onCompletion); };
exports.onHover = function (conn) { return registerHandler(conn.onHover); };
exports.onDocumentSymbol = function (conn) { return registerHandler(conn.onDocumentSymbol); };
exports.onWorkspaceSymbol = function (conn) { return registerHandler(conn.onWorkspaceSymbol); };
exports.onCodeAction = function (conn) { return registerHandler(conn.onCodeAction); };
exports.onDidChangeConfiguration = function (conn) { return registerHandler(conn.onDidChangeConfiguration); };
exports.publishDiagnostics = function (conn) { return function (params) { return function () { return conn.sendDiagnostics(params); }; }; };
exports.applyEdit = function (conn) { return function (edit) { return function () { return conn.workspace.applyEdit(edit); }; }; };
// export const onExecuteCommand = (conn: IConnection) => registerHandler(conn.onExecuteCommand);
exports.onExecuteCommand = function (conn) { return function (f) { return function () { return conn.onExecuteCommand(function (p) {
    conn.console.log(p.command);
    return 42;
}); }; }; };
