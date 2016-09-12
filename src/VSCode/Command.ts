import * as vscode from 'vscode';

export const register = (command: string) => (callback: (args: any[]) => () => {}) => () =>  
    vscode.commands.registerCommand(command, (...args) => callback(args)());