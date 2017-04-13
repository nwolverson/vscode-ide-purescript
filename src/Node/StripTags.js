exports.stripTags = function (s) {
    return function() {
        var striptags = require('striptags');
        return striptags(s);
    }
}