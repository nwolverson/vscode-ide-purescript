import { Range, Position } from 'vscode';

export const getStart = (r: Range) => r.start;
export const getEnd = (r: Range) => r.end;
export const mkRange = (start: Position) => (end: Position) => {
  new Range(start, end)
};
