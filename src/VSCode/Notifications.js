// module VSCode.Notifications

exports.showError = function(s) { return function() { require('vscode').window.showErrorMessage(s); return {}; }; }

exports.showInfo = function(s) { return function() { require('vscode').window.showInfoMessage(s); return {}; }; }

exports.showWarning = function(s) { return function() { require('vscode').window.showWarningMessage(s); return {}; }; }