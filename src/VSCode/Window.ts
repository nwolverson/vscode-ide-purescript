import { window, TextEditor, Position, Range } from 'vscode';

export const getActiveTextEditorImpl = <T>(nothing: T) => (just: (x: TextEditor) => T) => () =>
    window.activeTextEditor !== undefined ? just(window.activeTextEditor) : nothing;

export const getCursorBufferPosition = (ed : TextEditor) => () : Position => 
    ed.selection.active;

export const getSelectionRange = (ed : TextEditor) => () : Range => 
    ed.selection;

export const setStatusBarMessage = (message : string) => () => window.setStatusBarMessage(message);