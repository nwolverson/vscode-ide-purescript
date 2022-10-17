export function stripTags (s) {
    return function() {
        var striptags = require('striptags');
        return striptags(s);
    }
}