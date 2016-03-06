// module VSCode.Diagnostic

exports.mkDiagnostic = function(range) {
    return function(message) {
        return function(severity) {
            return new (require('vscode').Diagnostic)(range,message,severity);
        };
    };
};

exports.mkDiagnosticWithInfo = function(range) {
    return function(message) {
        return function(severity) {
            return function (x) {
              var diagnostic = new (require('vscode').Diagnostic)(range,message,severity);
              diagnostic.info = x;
              return diagnostic;
            }
        };
    };
};
