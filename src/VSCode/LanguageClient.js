"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
var vscode_languageclient_1 = require("vscode-languageclient");
var vscode_jsonrpc_1 = require("vscode-jsonrpc");
exports.sendCommandImpl = function (client) { return function (command) { return function (args) {
    return function (errCb) { return function (cb) { return function () {
        return client.sendRequest(vscode_languageclient_1.ExecuteCommandRequest.type, { command: command, arguments: args }).then(function (res) {
            cb(res)();
        }, function (err) {
            errCb(err)();
        });
    }; }; };
}; }; };
exports.onNotification0 = function (client) { return function (notification) { return function (cb) { return function () {
    return client.onNotification(new vscode_jsonrpc_1.NotificationType0(notification), cb);
}; }; }; };
