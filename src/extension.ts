import * as vscode from 'vscode'; 

import { PscIde } from './pscide';
import { PscHoverProvider } from './tooltips';
import { PscCompletionProvider } from './completion';

export function activate(context: vscode.ExtensionContext) {
	var pscIde = new PscIde();
	context.subscriptions.push(
		vscode.languages.registerHoverProvider('purescript', new PscHoverProvider(pscIde)),
		vscode.languages.registerCompletionItemProvider('purescript', new PscCompletionProvider(pscIde)),
		vscode.Disposable.from(pscIde)
	);
	pscIde.startServer();
}