"use strict";
var vscode_1 = require('vscode');
exports.showInputBox = function (options) { return function (cb) { return function () {
    return vscode_1.window.showInputBox(options).then(function (x) { return cb(x)(); });
}; }; };
exports.showQuickPickImpl = function (items) { return function (nothing) { return function (just) { return function (cb) { return function () {
    return vscode_1.window.showQuickPick(items).then(function (value) { return value === undefined ? cb(nothing)() : cb(just(value))(); });
}; }; }; }; };
exports.showQuickPickItemsImpl = function (items) { return function (nothing) { return function (just) { return function (cb) { return function () {
    return vscode_1.window.showQuickPick(items).then(function (value) { return value === undefined ? cb(nothing)() : cb(just(value))(); });
}; }; }; }; };
