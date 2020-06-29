"use strict";
// module VSCode.Position
Object.defineProperty(exports, "__esModule", { value: true });
exports.mkPosition = exports.getCharacter = exports.getLine = void 0;
var vscode_1 = require("vscode");
exports.getLine = function (p) { return p.line; };
exports.getCharacter = function (p) { return p.character; };
exports.mkPosition = function (x) { return function (y) { return new vscode_1.Position(x, y); }; };
