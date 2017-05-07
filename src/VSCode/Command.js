"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
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
    return (_a = vscode.commands).executeCommand.apply(_a, [command].concat(args));
    var _a;
}; }; };
exports.executeCb = function (command) { return function (args) { return function (cb) { return function () {
    return (_a = vscode.commands).executeCommand.apply(_a, [command].concat(args)).then(function (res) {
        console.log(res);
        cb(res);
    }, function (err) {
        console.error("Command error", err);
    });
    var _a;
}; }; }; };
