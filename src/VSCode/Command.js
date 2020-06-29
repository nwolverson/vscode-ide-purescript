"use strict";
var __spreadArrays = (this && this.__spreadArrays) || function () {
    for (var s = 0, i = 0, il = arguments.length; i < il; i++) s += arguments[i].length;
    for (var r = Array(s), k = 0, i = 0; i < il; i++)
        for (var a = arguments[i], j = 0, jl = a.length; j < jl; j++, k++)
            r[k] = a[j];
    return r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.executeCb = exports.execute = exports.register = void 0;
var vscode = require("vscode");
exports.register = function (command) { return function (callback) { return function () {
    return vscode.commands.registerCommand(command, function () {
        var args = [];
        for (var _i = 0; _i < arguments.length; _i++) {
            args[_i] = arguments[_i];
        }
        return callback(args)();
    });
}; }; };
exports.execute = function (command) { return function (args) { return function () {
    var _a;
    return (_a = vscode.commands).executeCommand.apply(_a, __spreadArrays([command], args));
}; }; };
exports.executeCb = function (command) { return function (args) { return function (cb) { return function () {
    var _a;
    return (_a = vscode.commands).executeCommand.apply(_a, __spreadArrays([command], args)).then(function (res) {
        console.log(res);
        cb(res);
    }, function (err) {
        console.error("Command error", err);
    });
}; }; }; };
