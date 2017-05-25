import { TextEditor, Range } from 'vscode';

export const setTextImpl = (ed : TextEditor) => (text : string) => (cb: (success: boolean) => () => {}) => () =>
    ed.edit(builder => builder.replace(new Range(0, 0, ed.document.lineCount, 0), text))
        .then(s => cb(s)());


export const setTextViaDiffImpl  = (ed : TextEditor) => (text : string) => (cb: (success: boolean) => () => {}) => () => {
    const oldLines = ed.document.getText().split(/\n/);
    const newLines = text.split(/\n/);

    for (var lineNo = 0;
        lineNo < oldLines.length
        && lineNo < newLines.length
        && oldLines[lineNo] === newLines[lineNo];
        lineNo++);
    if (lineNo == oldLines.length && lineNo == newLines.length) {
        cb(true);
        return;
    }
    for (var endLineNo = 0; 
        endLineNo < oldLines.length 
        && endLineNo < newLines.length 
        && newLines[newLines.length - endLineNo] === oldLines[oldLines.length - endLineNo];
        endLineNo++);
    const newText = newLines.slice(lineNo, newLines.length - endLineNo + 1).join("\n") + (newLines.length > 0 ? "\n" : "");

    ed.edit(builder => builder.replace(new Range(lineNo, 0, ed.document.lineCount - endLineNo + 1, 0), newText))
        .then(s => cb(s)());
};


export const setTextInRangeImpl = (ed : TextEditor) => (text : string) => (range : Range) => (cb: (success: boolean) => () => {}) => () =>
    ed.edit(builder => builder.replace(range, text))
        .then(s => cb(s)());

export const getDocument = (ed: TextEditor) => ed.document;
