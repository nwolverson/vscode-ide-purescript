// module VSCode.Location

import { Position, Location, Uri } from 'vscode';

export const mkLocation = (file : string) => (pos: Position) => new Location(Uri.file(file), pos); 
