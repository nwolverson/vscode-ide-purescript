// module VSCode.Window
"use strict";
var vscode_1 = require('vscode');
exports.getActiveTextEditorImpl = function (nothing) { return function (just) { return function () {
    return vscode_1.window.activeTextEditor !== undefined ? just(vscode_1.window.activeTextEditor) : nothing;
}; }; };
exports.getPath = function (ed) { return function () {
    return ed.document.fileName;
}; };
exports.getText = function (ed) { return function () {
    return ed.document.getText();
}; };
exports.setTextImpl = function (ed) { return function (text) { return function (cb) { return function () {
    return ed.edit(function (builder) { return builder.replace(new vscode_1.Range(0, 0, ed.document.lineCount, 0), text); })
        .then(function (s) { return cb(s)(); });
}; }; }; };
exports.setTextInRangeImpl = function (ed) { return function (text) { return function (range) { return function (cb) { return function () {
    return ed.edit(function (builder) { return builder.replace(range, text); })
        .then(function (s) { return cb(s)(); });
}; }; }; }; };
exports.getCursorBufferPosition = function (ed) { return function () {
    return ed.selection.active;
}; };
exports.getSelectionRange = function (ed) { return function () {
    return ed.selection;
}; };
exports.getTextInRange = function (ed) { return function (range) { return function () { return ed.document.getText(range); }; }; };
exports.lineAtPosition = function (ed) { return function (pos) { return function () { return ed.document.lineAt(pos).text; }; }; };
