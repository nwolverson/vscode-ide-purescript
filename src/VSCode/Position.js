// module VSCode.Position

exports.getLine = function(p) { return p.line; };
exports.getCharacter = function(p) { return p.character; };
exports.mkPosition = function(x) { return function(y) { return new (require('vscode').Position)(x,y); }; };
