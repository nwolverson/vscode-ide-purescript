// module VSCode.Window

import { window, TextEditor, Position, Range } from 'vscode';
import * as vscode from 'vscode';

export const getActiveTextEditorImpl = <T>(nothing: T) => (just: (x: TextEditor) => T) => () =>
    window.activeTextEditor !== undefined ? just(window.activeTextEditor) : nothing;

export const getPath = (ed : TextEditor) => () =>
    ed.document.fileName;

export const getText = (ed : TextEditor) => () =>
    ed.document.getText()

export const setTextImpl = (ed : TextEditor) => (text : string) => (cb: (success: boolean) => () => {}) => () =>
    ed.edit(builder => builder.replace(new Range(0, 0, ed.document.lineCount, 0), text))
        .then(s => cb(s)());

export const setTextInRangeImpl = (ed : TextEditor) => (text : string) => (range : Range) => (cb: (success: boolean) => () => {}) => () =>
    ed.edit(builder => builder.replace(range, text))
        .then(s => cb(s)());

export const getCursorBufferPosition = (ed : TextEditor) => () : Position => 
    ed.selection.active;

export const getSelectionRange = (ed : TextEditor) => () : Range => 
    ed.selection;

export const getTextInRange = (ed : TextEditor) => (range : Range) => () => ed.document.getText(range);

export const lineAtPosition = (ed: TextEditor) => (pos : Position) => () : string => ed.document.lineAt(pos).text;