import * as vscode from 'vscode';

export function getWord(document: vscode.TextDocument, position: vscode.Position) {
	const wordRange = document.getWordRangeAtPosition(position) 
		|| new vscode.Range(position, position);
	const word = document.getText(wordRange);
	
	const prefix = document.getText(new vscode.Range(position.with(undefined, 0), wordRange.start));
	const moduleRegex = /(?:^|[^A-Za-z_.])((?:[A-Z][A-Za-z0-9]*\.)*(?:[A-Z][A-Za-z0-9]*))\.$/;
	const m = prefix.match(moduleRegex);
	const modulePrefix = m ? m[1] : "";
	var fullRange = wordRange.with(wordRange.start.translate(undefined, modulePrefix.length > 0 ? -modulePrefix.length - 1 : 0));

	return {
		word: word,
		module: modulePrefix,
		range: fullRange
	};
}