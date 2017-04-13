import { InputBoxOptions, window, QuickPickItem } from 'vscode';

export const showInputBox = (options : InputBoxOptions) => (cb: (value: string) => () => {}) => () =>
    window.showInputBox(options).then(x => cb(x)());
    
export const showQuickPickImpl = (items: string[]) => <T>(nothing: T) => (just: ((s: string) => T)) => (cb: (value: T) => () => {}) => () =>
    window.showQuickPick(items).then((value: string) => value === undefined ? cb(nothing)() : cb(just(value))());

export const showQuickPickItemsImpl = (items: QuickPickItem[]) => <T>(nothing: T) => (just: ((s: QuickPickItem) => T)) => (cb: (value: T) => () => {}) => () =>
    window.showQuickPick(items).then((value: QuickPickItem) => value === undefined ? cb(nothing)() : cb(just(value))());
