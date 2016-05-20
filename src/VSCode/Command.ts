// module VSCode.Command

import * as vscode from 'vscode';

export const register = (command: string) => (callback: () => any) => () =>  
    vscode.commands.registerCommand(command, callback);