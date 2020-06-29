"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.setStatusBarMessage = exports.getSelectionRange = exports.getCursorBufferPosition = exports.getActiveTextEditorImpl = void 0;
var vscode_1 = require("vscode");
exports.getActiveTextEditorImpl = function (nothing) { return function (just) { return function () {
    return vscode_1.window.activeTextEditor !== undefined ? just(vscode_1.window.activeTextEditor) : nothing;
}; }; };
exports.getCursorBufferPosition = function (ed) { return function () {
    return ed.selection.active;
}; };
exports.getSelectionRange = function (ed) { return function () {
    return ed.selection;
}; };
exports.setStatusBarMessage = function (message) { return function () { return vscode_1.window.setStatusBarMessage(message); }; };
