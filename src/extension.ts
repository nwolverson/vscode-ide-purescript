import * as vscode from 'vscode';
import { resolve } from 'path';
import * as path from 'path';
import { workspace, Disposable, ExtensionContext } from 'vscode';
import { LanguageClient, LanguageClientOptions, SettingMonitor, ServerOptions, TransportKind, RevealOutputChannelOn } from 'vscode-languageclient';
import * as lc from 'vscode-languageclient';

export function activate(context: vscode.ExtensionContext) {
    const activatePS = require('./bundle');

    // If the extension is launched in debug mode then the debug server options are used
    // Otherwise the run options are used
    const opts = { module: 'purescript-language-server', transport: TransportKind.ipc };
    const serverOptions: ServerOptions = opts;
    
    // Options to control the language client
    const clientOptions: LanguageClientOptions = {
        // Register the server for plain text documents
        documentSelector: ['purescript'],
        synchronize: {
            configurationSection: 'purescript',
            fileEvents: workspace.createFileSystemWatcher('**/*.purs')
        },
        revealOutputChannelOn: RevealOutputChannelOn.Never,
        errorHandler: { 
            error: (e,m,c) => { console.error(e,m,c); return lc.ErrorAction.Continue  },
            closed: () => lc.CloseAction.DoNotRestart
        }
    };
	
	// Create the language client and start the client.
    const client = new LanguageClient('PureScript', 'IDE PureScript', serverOptions, clientOptions);

	const disposable = client.start();
    client.onReady().then(() => activatePS(client));
    
	// Push the disposable to the context's subscriptions so that the 
	// client can be deactivated on extension deactivation
	context.subscriptions.push(disposable);
}


