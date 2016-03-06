// module VSCode.Range

exports.getStart = function (r) { return r.start; };
exports.getEnd = function (r) { return r.end; };
exports.mkRange = function (start) { return function (end) { return new (require('vscode').Range)(start, end); }; };
