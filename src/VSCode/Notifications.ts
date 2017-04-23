// module VSCode.Notifications

import * as vscode from 'vscode';

export const createOutputChannel = (s: string) => () => vscode.window.createOutputChannel(s);

export const appendOutput = (c: vscode.OutputChannel) => (s: string) => () => c.append(s);

export const appendOutputLine = (c: vscode.OutputChannel) => (s: string) => () => c.appendLine(s);

export const clearOutput = (c: vscode.OutputChannel) => () => c.clear();

export const showError = (s: string) => () =>
    vscode.window.showErrorMessage(s);

export const showInfo = (s: string) => () =>
    vscode.window.showInformationMessage(s);

export const showWarning = (s: string) => () =>
    vscode.window.showWarningMessage(s);
