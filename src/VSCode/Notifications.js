"use strict";
// module VSCode.Notifications
Object.defineProperty(exports, "__esModule", { value: true });
var vscode = require("vscode");
exports.createOutputChannel = function (s) { return function () { return vscode.window.createOutputChannel(s); }; };
exports.appendOutput = function (c) { return function (s) { return function () { return c.append(s); }; }; };
exports.appendOutputLine = function (c) { return function (s) { return function () { return c.appendLine(s); }; }; };
exports.clearOutput = function (c) { return function () { return c.clear(); }; };
exports.showError = function (s) { return function () {
    return vscode.window.showErrorMessage(s);
}; };
exports.showInfo = function (s) { return function () {
    return vscode.window.showInformationMessage(s);
}; };
exports.showWarning = function (s) { return function () {
    return vscode.window.showWarningMessage(s);
}; };
