import * as vscode from 'vscode';
import { resolve } from 'path';
import { workspace, Disposable, ExtensionContext } from 'vscode';
import { LanguageClient, LanguageClientOptions, SettingMonitor, ServerOptions, TransportKind, ErrorAction, CloseAction } from 'vscode-languageclient';

export function activate(context: vscode.ExtensionContext) {
    const ps = require('./bundle')();
    
    // If the extension is launched in debug mode then the debug server options are used
    // Otherwise the run options are used
    const serverOptions: ServerOptions = {
        run : { command: 'purescript-language-server', args: [ "--stdio"] },
        debug: {
            command: 'node',
            args: [ "--inspect=6011", "--nolazy",
                resolve(vscode.extensions.getExtension('nwolverson.ide-purescript').extensionPath,
                    "./language-server/cli.js"),
                "--stdio"
            ]
        }
    }
    
    // Options to control the language client
    const clientOptions: LanguageClientOptions = {
        // Register the server for plain text documents
        documentSelector: ['purescript'],
        synchronize: {
            configurationSection: 'purescript',
            fileEvents: workspace.createFileSystemWatcher('**/*.purs')
        },
        errorHandler: { 
            error: (e,m,c) => { console.error(e,m,c); return ErrorAction.Continue  },
            closed: () => CloseAction.DoNotRestart
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


