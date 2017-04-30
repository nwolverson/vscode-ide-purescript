import * as vscode from 'vscode';

import { BuildActionProvider, CodeActionCommands } from './codeActions';
import { PscError, PscPosition, PscErrorSuggestion, PscResults, QuickFix, FileDiagnostic, BuildResult } from './build';

import { resolve } from 'path';


import * as path from 'path';

import { workspace, Disposable, ExtensionContext } from 'vscode';
import { LanguageClient, LanguageClientOptions, SettingMonitor, ServerOptions, TransportKind } from 'vscode-languageclient';
import * as lc from 'vscode-languageclient';


// const getText = doc => (a,b,c,d) => doc.getText(new vscode.Range(new vscode.Position(a,b), new vscode.Position(c,d)));


export function activate(context: vscode.ExtensionContext) {
    const ps = require('./bundle')();
    const config = vscode.workspace.getConfiguration("purescript");

    // const useDoc = (doc : vscode.TextDocument) => {
    //     if (doc.fileName && doc.fileName.endsWith('.purs')) {
    //         ps.updateFile(doc.fileName, doc.getText());
    //     }
    // };

    // ps.activate()
    //     .then(() => {
    //         // if (vscode.window.activeTextEditor) {
    //         //     useDoc(vscode.window.activeTextEditor.document)
    //         // }
    //     })
    //     .catch((err) => {
    //         vscode.window.showErrorMessage("Error starting psc-ide");
    //         console.error(err);
    //     });


    // const diagnosticCollection = vscode.languages.createDiagnosticCollection("purescript");
    // const buildProvider = new BuildActionProvider();
    // const onBuildResult = (notify : boolean) => (res : BuildResult) => {
    //     if (res.success) {
    //         let code = 0;
    //         const map = new Map<string, vscode.Diagnostic[]>();

    //         const actionMap = new Map<number, FileDiagnostic>();
    //         res.diagnostics.forEach(d => {
    //             ++code;
    //             d.diagnostic.code = code;
    //             actionMap.set(code, d);
                
    //             const filename = resolve(vscode.workspace.rootPath, d.filename);
    //             console.log(filename);
    //             const entries = map.get(filename) || [];
    //             entries.push(d.diagnostic);
    //             map.set(filename, entries);
    //         });
            
    //         if (res.quickBuild) {
    //             diagnosticCollection.set(vscode.Uri.file(res.file), map.get(res.file) || []);
    //         } else {
    //             // If I don't clear before set, last error remains when fixed
    //             diagnosticCollection.clear();

    //             const diags = <[vscode.Uri, vscode.Diagnostic[]][]><Object> Array.from(map.entries()).map(([url, diags]) => [vscode.Uri.file(url), diags]);
    //             diagnosticCollection.set(diags);
    //         }

    //         buildProvider.setBuildResults(actionMap);

    //         if (notify) {
    //             if (res.diagnostics.some(x => x.diagnostic.severity == vscode.DiagnosticSeverity.Error)) {
    //                 vscode.window.showWarningMessage("Build completed with errors");
    //             } else {
    //                 vscode.window.showInformationMessage("Build succeeded");
    //             }
    //         }
            
    //     } else {
    //         vscode.window.showErrorMessage("Build error :(");
    //     }
    // };

    // vscode.workspace.onDidChangeTextDocument(e => console.log(e.contentChanges));
    // context.subscriptions.push(
    //     new vscode.Disposable(ps.deactivate)
    //   , vscode.window.onDidChangeActiveTextEditor((editor) => {
    //       if (editor) {
    //         useDoc(editor.document);
    //       }
    //   })
    //   , vscode.workspace.onDidSaveTextDocument(doc => {
    //       if (doc.fileName.endsWith(".purs")) {
    //         if (config.get<boolean>('fastRebuild')) {
    //             ps.quickBuild(doc.fileName)
    //                 .then(onBuildResult(false))
    //                 .catch(err => {
    //                     console.error(err);
    //                     vscode.window.showErrorMessage("Rebuild error");
    //                 })
    //         }
    //         useDoc(doc);
    //       }
    //     })
    //   , vscode.languages.registerHoverProvider('purescript', {
    //     provideHover: (doc, pos, tok) =>
    //         ps.getTooltips(pos.line, pos.character, getText(doc))
    //             .then(result => result !== null ? new vscode.Hover(result) : null)
    //             .catch((err) => {
    //                 console.error("Hover error", err);
    //             })
    //     })

                    // item.command = { 
                    //     command: "purescript.addCompletionImport", 
                    //     title: "Add completion import", 
                    //     arguments: [ pos.line, pos.character, it ] 
                    // };

    //   , vscode.commands.registerCommand("purescript.build", function() {
    //       const config = vscode.workspace.getConfiguration("purescript");
    //       ps.build(config.get<string>("buildCommand"), vscode.workspace.rootPath)
    //         .then(onBuildResult(true))
    //         .catch(err => {
    //             console.error(err);
    //             vscode.window.showErrorMessage("Build error");
    //         });
    //   })
    //   , vscode.languages.registerCodeActionsProvider('purescript', buildProvider)
    //   , vscode.Disposable.from(new CodeActionCommands())
    // );


    let serverModule = context.asAbsolutePath(path.join('out', 'src', 'server.js'));
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
    // vscode.commands.registerCommand("purescript:test", () => {
    //     // client.sendRequest()
    // })
    
    console.log("started server");

	// Push the disposable to the context's subscriptions so that the 
	// client can be deactivated on extension deactivation
	context.subscriptions.push(disposable);
}


