// module VSCode.Notifications
"use strict";
var vscode = require('vscode');
exports.showError = function (s) { return function () {
    return vscode.window.showErrorMessage(s);
}; };
exports.showInfo = function (s) { return function () {
    return vscode.window.showInformationMessage(s);
}; };
exports.showWarning = function (s) { return function () {
    return vscode.window.showWarningMessage(s);
}; };
