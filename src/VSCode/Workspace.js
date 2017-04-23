"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
var vscode_1 = require("vscode");
exports.getConfiguration = function (section) { return function () { return vscode_1.workspace.getConfiguration(section); }; };
exports.getValue = function (config) { return function (key) { return function () { return config.get(key); }; }; };
exports.rootPath = function () { return vscode_1.workspace.rootPath; };
