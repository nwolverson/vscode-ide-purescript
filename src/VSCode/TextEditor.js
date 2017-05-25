"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
var vscode_1 = require("vscode");
exports.setTextImpl = function (ed) { return function (text) { return function (cb) { return function () {
    return ed.edit(function (builder) { return builder.replace(new vscode_1.Range(0, 0, ed.document.lineCount, 0), text); })
        .then(function (s) { return cb(s)(); });
}; }; }; };
exports.setTextViaDiffImpl = function (ed) { return function (text) { return function (cb) { return function () {
    var oldLines = ed.document.getText().split(/\n/);
    var newLines = text.split(/\n/);
    for (var lineNo = 0; lineNo < oldLines.length
        && lineNo < newLines.length
        && oldLines[lineNo] === newLines[lineNo]; lineNo++)
        ;
    if (lineNo == oldLines.length && lineNo == newLines.length) {
        cb(true);
        return;
    }
    for (var endLineNo = 0; endLineNo < oldLines.length
        && endLineNo < newLines.length
        && newLines[newLines.length - endLineNo] === oldLines[oldLines.length - endLineNo]; endLineNo++)
        ;
    var newText = newLines.slice(lineNo, newLines.length - endLineNo + 1).join("\n") + (newLines.length > 0 ? "\n" : "");
    ed.edit(function (builder) { return builder.replace(new vscode_1.Range(lineNo, 0, ed.document.lineCount - endLineNo + 1, 0), newText); })
        .then(function (s) { return cb(s)(); });
}; }; }; };
exports.setTextInRangeImpl = function (ed) { return function (text) { return function (range) { return function (cb) { return function () {
    return ed.edit(function (builder) { return builder.replace(range, text); })
        .then(function (s) { return cb(s)(); });
}; }; }; }; };
exports.getDocument = function (ed) { return ed.document; };
