// module VSCode.Input

import { InputBoxOptions, window } from 'vscode';

export const showInputBox = (options : InputBoxOptions) => (cb: (value: string) => () => {}) => () =>
    window.showInputBox(options).then(x => cb(x)());
    
export const showQuickPickImpl = (items: string[]) => <T>(nothing: T) => (just: ((s: string) => T)) => (cb: (value: T) => () => {}) => () =>
    window.showQuickPick(items).then((value: string) => value === undefined ? cb(nothing)() : cb(just(value))());
    
    
import * as vscode from 'vscode';
