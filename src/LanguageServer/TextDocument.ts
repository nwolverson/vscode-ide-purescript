import { TextDocument, Position } from 'vscode-languageserver';

export const getText = (document: TextDocument) => () => document.getText();

export const offsetAtPosition = (document: TextDocument) => (pos: Position) => () => document.offsetAt(pos);

export const positionAtOffset = (document: TextDocument) => (offset: number) => () => document.positionAt(offset);

