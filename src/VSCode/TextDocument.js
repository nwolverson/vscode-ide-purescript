"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.lineAtPosition = exports.getTextInRange = exports.getText = exports.getPath = exports.openTextDocument = void 0;
var vscode = require("vscode");
exports.openTextDocument = function (fileName) { return function (cb) { return function () {
    return vscode.workspace.openTextDocument(fileName).then(function (doc) { return cb(doc)(); });
}; }; };
exports.getPath = function (doc) { return function () { return doc.fileName; }; };
exports.getText = function (doc) { return function () { return doc.getText(); }; };
exports.getTextInRange = function (doc) { return function (range) { return function () { return doc.getText(range); }; }; };
exports.lineAtPosition = function (doc) { return function (pos) { return function () { return doc.lineAt(pos).text; }; }; };
