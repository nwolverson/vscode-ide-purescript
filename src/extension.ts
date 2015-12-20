import * as vscode from 'vscode'; 

import { PscIde } from './pscide';
import { PscHoverProvider } from './tooltips';
import { PscCompletionProvider } from './completion';
import { EditorContext } from './editor-context';
import { build } from './build';

export function activate(context: vscode.ExtensionContext) {
	var editorContext = new EditorContext();
	var pscIde = new PscIde(editorContext);
 
	context.subscriptions.push(
		vscode.languages.registerHoverProvider('purescript', new PscHoverProvider(pscIde)),
		vscode.languages.registerCompletionItemProvider('purescript', new PscCompletionProvider(pscIde)),
		vscode.Disposable.from(pscIde),
		vscode.Disposable.from(editorContext),
        vscode.commands.registerCommand("purescript.build", build)
	);
	pscIde.activate();
}