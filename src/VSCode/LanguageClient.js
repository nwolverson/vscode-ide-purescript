"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.onNotification0 = exports.sendCommandImpl = void 0;
var node_1 = require("vscode-languageclient/node");
exports.sendCommandImpl = function (client) { return function (command) { return function (args) {
    return function (errCb) { return function (cb) { return function () {
        return client.sendRequest(node_1.ExecuteCommandRequest.type, { command: command, arguments: args }).then(function (res) {
            cb(res)();
        }, function (err) {
            errCb(err)();
        });
    }; }; };
}; }; };
exports.onNotification0 = function (client) { return function (notification) { return function (cb) { return function () {
    return client.onNotification(notification, cb);
}; }; }; };
