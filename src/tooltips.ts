import * as vscode from 'vscode';
import { PscIde } from './pscIde';
import { getWord } from './utils';

export class PscHoverProvider implements vscode.HoverProvider {
	constructor(private pscIde : PscIde) {}
	
	provideHover(document: vscode.TextDocument, position: vscode.Position, token: vscode.CancellationToken) {
		var info = getWord(document, position);
		return this.pscIde.getType(info.word, info.module).then(function (result) {
			if (result && result.length > 0) {
				return new vscode.Hover(`**${info.word}** :: ${result}`, info.range);
			}	
		});
	}
} 