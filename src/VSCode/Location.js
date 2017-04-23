// module VSCode.Location
"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
var vscode_1 = require("vscode");
exports.mkLocation = function (file) { return function (pos) { return new vscode_1.Location(vscode_1.Uri.file(file), pos); }; };
