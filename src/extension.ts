import * as vscode from 'vscode';
import { resolve } from 'path';
import * as path from 'path';
import { workspace, Disposable, ExtensionContext } from 'vscode';
import { LanguageClient, LanguageClientOptions, SettingMonitor, ServerOptions, TransportKind } from 'vscode-languageclient';
import * as lc from 'vscode-languageclient';

export function activate(context: vscode.ExtensionContext) {
    const ps = require('./bundle')();
    const config = vscode.workspace.getConfiguration("purescript");
    let serverModule = context.asAbsolutePath(path.join('language-server', 'server.js'));
    // The debug options for the server
    let debugOptions = { execArgv: ["--nolazy", "--debug=6010"] };
    
    // If the extension is launched in debug mode then the debug server options are used
    // Otherwise the run options are used
    let serverOptions: ServerOptions = {
        run : { module: serverModule, transport: TransportKind.ipc },
        debug: { module: serverModule, transport: TransportKind.ipc, options: debugOptions }
    }
    
    // Options to control the language client
    let clientOptions: LanguageClientOptions = {
        // Register the server for plain text documents
        documentSelector: ['purescript'],
        synchronize: {
            configurationSection: 'purescript',
            fileEvents: workspace.createFileSystemWatcher('**/*.purs')
        },
        errorHandler: { 
            error: (e,m,c) => { console.error(e,m,c); return lc.ErrorAction.Continue  },
            closed: () => lc.CloseAction.DoNotRestart
        }
    };
	
	// Create the language client and start the client.
    const client = new LanguageClient('PureScript', 'IDE PureScript', serverOptions, clientOptions);

	const disposable = client.start();
    client.onReady().then(() => {
        ps.activate(client)();
    });
    
	// Push the disposable to the context's subscriptions so that the 
	// client can be deactivated on extension deactivation
	context.subscriptions.push(disposable);
}


