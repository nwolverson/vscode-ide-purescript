"use strict";
var vscode = require('vscode');
exports.register = function (command) { return function (callback) { return function () {
    return vscode.commands.registerCommand(command, function () {
        var args = [];
        for (var _i = 0; _i < arguments.length; _i++) {
            args[_i - 0] = arguments[_i];
        }
        return callback(args)();
    });
}; }; };
