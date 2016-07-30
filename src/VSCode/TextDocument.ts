import * as vscode from 'vscode';
import { TextDocument, Position, Range } from 'vscode';

export const openTextDocument =  (fileName: string) => (cb: ((doc: vscode.TextDocument) => () => {})) => () => 
    vscode.workspace.openTextDocument(fileName).then(doc => cb(doc)());

export const getPath = (doc : TextDocument) => () => doc.fileName;

export const getText = (doc : TextDocument) => () => doc.getText();

export const getTextInRange = (doc : TextDocument) => (range : Range) => () => doc.getText(range);

export const lineAtPosition = (doc : TextDocument) => (pos : Position) => () => doc.lineAt(pos).text;