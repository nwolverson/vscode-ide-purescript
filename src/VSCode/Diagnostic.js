"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.mkDiagnosticWithInfo = exports.mkDiagnostic = void 0;
var vscode_1 = require("vscode");
exports.mkDiagnostic = function (range) { return function (message) { return function (severity) {
    return new vscode_1.Diagnostic(range, message, severity);
}; }; };
exports.mkDiagnosticWithInfo = function (range) { return function (message) { return function (severity) { return function (x) {
    var diagnostic = new vscode_1.Diagnostic(range, message, severity);
    diagnostic.info = x;
    return diagnostic;
}; }; }; };
