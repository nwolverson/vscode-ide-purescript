// module VSCode.Location
"use strict";
var vscode_1 = require('vscode');
exports.mkLocation = function (file) { return function (pos) { return new vscode_1.Location(vscode_1.Uri.file(file), pos); }; };
