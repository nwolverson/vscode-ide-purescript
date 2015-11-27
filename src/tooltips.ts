import * as vscode from 'vscode';
import { PscIde } from './pscIde';

export class PscHoverProvider implements vscode.HoverProvider {
	constructor(private pscIde : PscIde) {}
	
	provideHover(document: vscode.TextDocument, position: vscode.Position, token: vscode.CancellationToken) {
		const wordRange = document.getWordRangeAtPosition(position);
		const word = document.getText(wordRange);
		return this.pscIde.getType(word, "").then(function (result) {
			if (result && result.length > 0) {
				return new vscode.Hover(`**${word}** :: ${result}`);
			}	
		});
	}
} 