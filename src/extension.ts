import * as vscode from 'vscode'; 

import { PscIde } from './pscide';
import { PscHoverProvider } from './tooltips';

export function activate(context: vscode.ExtensionContext) {
	context.subscriptions.push(
		vscode.languages.registerHoverProvider('purescript', new PscHoverProvider())
	);
}