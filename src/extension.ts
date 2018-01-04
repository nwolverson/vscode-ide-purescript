import { workspace, Disposable, ExtensionContext, OutputChannel, WorkspaceFolder, Uri, TextDocument, window  } from 'vscode';
import { LanguageClient, LanguageClientOptions, SettingMonitor, ServerOptions, TransportKind, RevealOutputChannelOn, ErrorAction, CloseAction } from 'vscode-languageclient';

const clients: Map<string, LanguageClient> = new Map();

export function activate(context: ExtensionContext) {
    const activatePS = require('./bundle');

    // If the extension is launched in debug mode then the debug server options are used
    // Otherwise the run options are used
    const opts = { module: 'purescript-language-server', transport: TransportKind.ipc };
    const serverOptions: ServerOptions = opts;
    const output = window.createOutputChannel("IDE PureScript");
    
    // Options to control the language client
    const clientOptions = (folder: WorkspaceFolder): LanguageClientOptions => ({
        // Register only for PureScript documents in the given root folder
        documentSelector: [
            { scheme: 'file', language: 'purescript', pattern: `${folder.uri.fsPath}/**/*` }
        ],
        workspaceFolder: folder,
        synchronize: {
            configurationSection: 'purescript',
            fileEvents: workspace.createFileSystemWatcher('**/*.purs')
        },
        outputChannel: output,
        revealOutputChannelOn: RevealOutputChannelOn.Never,
        errorHandler: { 
            error: (e,m,c) => { console.error(e,m,c); return ErrorAction.Continue  },
            closed: () => CloseAction.DoNotRestart
        }
    });

    function didOpenTextDocument(document: TextDocument): void {
        if (document.languageId !== 'purescript' || document.uri.scheme !== 'file') {
            return;
        }

        const folder = workspace.getWorkspaceFolder(document.uri);
        if (!folder) {
            console.log("Didn't find workspace folder for " + document.uri);
            return;
        }
        
        if (!clients.has(folder.uri.toString())) {
            const client = new LanguageClient('PureScript', 'IDE PureScript', serverOptions, clientOptions(folder));
            client.registerProposedFeatures();

            client.onReady().then(() => activatePS(client));
            client.start();
            clients.set(folder.uri.toString(), client);
        }
    }

    workspace.onDidOpenTextDocument(didOpenTextDocument);
    workspace.textDocuments.forEach(didOpenTextDocument);
    workspace.onDidChangeWorkspaceFolders((event) => {
        for (const folder of event.removed) {
            const client = clients.get(folder.uri.toString());
            if (client) {
                clients.delete(folder.uri.toString());
                client.stop();
            }
        }
    });
}
export function deactivate(): Thenable<void> {
	let promises: Thenable<void>[] = [];
	for (let client of Array.from(clients.values())) {
		promises.push(client.stop());
	}
	return Promise.all(promises).then(() => undefined);
}
