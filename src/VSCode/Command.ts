import * as vscode from 'vscode';

export const register = (command: string) => (callback: (args: any[]) => () => {}) => () =>  
    vscode.commands.registerCommand(command, (...args) => callback(args)());

export const execute = (command: string) => (args: any[]) => () =>
    vscode.commands.executeCommand(command, ...args);


export const executeCb = (command: string) => (args: any[]) => <T>(cb: (arg: T) => () => {}) => () =>
    vscode.commands.executeCommand<T>(command, ...args).then(res => {
        console.log(res);
        cb(res)
    });
