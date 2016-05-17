// module VSCode.Notifications

import * as vscode from 'vscode';

export const showError = (s: string) => () =>
    vscode.window.showErrorMessage(s);

export const showInfo = (s: string) => () =>
    vscode.window.showInformationMessage(s);

export const showWarning = (s: string) => () =>
    vscode.window.showWarningMessage(s);
