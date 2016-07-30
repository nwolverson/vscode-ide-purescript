"use strict";
var vscode_1 = require('vscode');
exports.setTextImpl = function (ed) { return function (text) { return function (cb) { return function () {
    return ed.edit(function (builder) { return builder.replace(new vscode_1.Range(0, 0, ed.document.lineCount, 0), text); })
        .then(function (s) { return cb(s)(); });
}; }; }; };
exports.setTextInRangeImpl = function (ed) { return function (text) { return function (range) { return function (cb) { return function () {
    return ed.edit(function (builder) { return builder.replace(range, text); })
        .then(function (s) { return cb(s)(); });
}; }; }; }; };
exports.getDocument = function (ed) { return ed.document; };
