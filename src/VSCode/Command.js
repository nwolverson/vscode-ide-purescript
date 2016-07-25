// module VSCode.Command
"use strict";
var vscode = require('vscode');
exports.register = function (command) { return function (callback) { return function () {
    return vscode.commands.registerCommand(command, callback);
}; }; };
