import { TextEditor, Range } from 'vscode';

export const setTextImpl = (ed : TextEditor) => (text : string) => (cb: (success: boolean) => () => {}) => () =>
    ed.edit(builder => builder.replace(new Range(0, 0, ed.document.lineCount, 0), text))
        .then(s => cb(s)());

export const setTextInRangeImpl = (ed : TextEditor) => (text : string) => (range : Range) => (cb: (success: boolean) => () => {}) => () =>
    ed.edit(builder => builder.replace(range, text))
        .then(s => cb(s)());

export const getDocument = (ed: TextEditor) => ed.document;
