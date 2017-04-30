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
