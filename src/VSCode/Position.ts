// module VSCode.Position

import { Position } from 'vscode';

export const getLine = (p: Position) => p.line;
export const getCharacter = (p: Position) => p.character;
export const mkPosition = (x: number) => (y: number) => new Position(x, y);