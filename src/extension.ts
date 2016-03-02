import * as vscode from 'vscode'; 

import { PscIde } from './pscide';
import { PscHoverProvider } from './tooltips';
import { PscCompletionProvider } from './completion';
import { EditorContext } from './editor-context';
import { build } from './build';
import { BuildActionProvider, CodeActionCommands } from './codeActions';

export function activate(context: vscode.ExtensionContext) {
	var editorContext = new EditorContext();
	var pscIde = new PscIde(editorContext);
 
    var buildProvider = new BuildActionProvider();
    console.log("Requiring");
    var main = require('./bundle');
    console.log("calling main")
    
    
    var ps = main();
    
    console.log("Required/called");
	context.subscriptions.push(
		vscode.languages.registerHoverProvider('purescript', new PscHoverProvider(pscIde)),
		vscode.languages.registerCompletionItemProvider('purescript', new PscCompletionProvider(pscIde)),
        vscode.languages.registerCodeActionsProvider('purescript', buildProvider),
		vscode.Disposable.from(pscIde),
		vscode.Disposable.from(editorContext),
        // vscode.commands.registerCommand("purescript.build", function() {
        //     build().then(result => buildProvider.setBuildResults(result))
        // }),
        vscode.commands.registerCommand("purescript.build", function() {
            ps.build();
        }),
        vscode.Disposable.from(new CodeActionCommands())
	);
	pscIde.activate();
}