import * as vscode from 'vscode';

import { BuildActionProvider, CodeActionCommands } from './codeActions';
import { PscError, PscPosition, PscErrorSuggestion, PscResults, QuickFix, FileDiagnostic, BuildResult } from './build';

const getText = doc => (a,b,c,d) => doc.getText(new vscode.Range(new vscode.Position(a,b), new vscode.Position(c,d)));

const convSymbolInformation = it => {
    let kind;
    if (/^[A-Z]/.test(it.identifier)) {
        kind = vscode.SymbolKind.Class;
    } else if (/->/.test(it.identType)) {
        kind = vscode.SymbolKind.Function;
    } else {
        kind = vscode.SymbolKind.Property;
    }
    return new vscode.SymbolInformation(it.identifier, kind, it.moduleName,
        new vscode.Location(vscode.Uri.file(it.fileName), it.range))
};

export function activate(context: vscode.ExtensionContext) {
    const ps = require('./bundle')();
    const config = vscode.workspace.getConfiguration("purescript");

    const useDoc = (doc : vscode.TextDocument) =>
        ps.updateFile(doc.fileName, doc.getText());

    ps.activate()
        .then(() => {
            if (vscode.window.activeTextEditor) {
                useDoc(vscode.window.activeTextEditor.document)
            }
        })
        .catch((err) => {
            vscode.window.showErrorMessage("Error starting psc-ide");
            console.error(err);
        });


    const diagnosticCollection = vscode.languages.createDiagnosticCollection("purescript");
    const buildProvider = new BuildActionProvider();
    const onBuildResult = (notify : boolean) => (res : BuildResult) => {
        if (res.success) {
            let code = 0;
            const map = new Map<string, vscode.Diagnostic[]>();

            const actionMap = new Map<number, FileDiagnostic>();
            res.diagnostics.forEach(d => {
                ++code;
                d.diagnostic.code = code;
                actionMap.set(code, d);
                const entries = map.get(d.filename) || [];
                entries.push(d.diagnostic);
                map.set(d.filename, entries);
            });
            const diags = <[vscode.Uri, vscode.Diagnostic[]][]><Object> Array.from(map.entries()).map(([url, diags]) => [vscode.Uri.file(url), diags]);

            // If I don't clear before set, last error remains when fixed
            diagnosticCollection.clear();

            diagnosticCollection.set(diags);

            buildProvider.setBuildResults(actionMap);

            if (notify) {
                if (res.diagnostics.some(x => x.diagnostic.severity == vscode.DiagnosticSeverity.Error)) {
                    vscode.window.showWarningMessage("Build completed with errors");
                } else {
                    vscode.window.showInformationMessage("Build succeeded");
                }
            }
            
        } else {
            vscode.window.showErrorMessage("Build error :(");
        }
    };

    // vscode.workspace.onDidChangeTextDocument(e => console.log(e.contentChanges));
    context.subscriptions.push(
        new vscode.Disposable(ps.deactivate)
      , vscode.window.onDidChangeActiveTextEditor((editor) => {
          if (editor) {
            useDoc(editor.document);
          }
      })
      , vscode.workspace.onDidSaveTextDocument(doc => {
          if (doc.fileName.endsWith(".purs")) {
            if (config.get<boolean>('fastRebuild')) {
                ps.quickBuild(doc.fileName)
                    .then(onBuildResult(false))
                    .catch(err => {
                        console.error(err);
                        vscode.window.showErrorMessage("Rebuild error");
                    })
            }
            useDoc(doc);
          }
        })
      , vscode.languages.registerHoverProvider('purescript', {
        provideHover: (doc, pos, tok) =>
            ps.getTooltips(pos.line, pos.character, getText(doc))
                .then(result => result !== null ? new vscode.Hover(result) : null)
                .catch((err) => {
                    console.error("Hover error", err);
                })
        })
      , vscode.languages.registerCompletionItemProvider('purescript', {
            provideCompletionItems: (doc, pos, _) => ps.getCompletions(pos.line, pos.character, getText(doc)).
                then(result => result.map(it => {
                    const item = new vscode.CompletionItem(it.identifier);
                    item.detail = it["type'"];
                    if (/^[A-Z]/.test(it.identifier)) {
                        item.kind = vscode.CompletionItemKind.Class;
                    } else if (/->/.test(it["type'"])) {
                        item.kind = vscode.CompletionItemKind.Function;
                    } else {
                        item.kind = vscode.CompletionItemKind.Value;
                    }
                    
                    item.command = { 
                        command: "purescript.addCompletionImport", 
                        title: "Add completion import", 
                        arguments: [ pos.line, pos.character, it ] 
                    };

                    return item;
                }))
            .catch(err => console.error("Completion error", err))
        })
      , vscode.languages.registerDefinitionProvider('purescript', {
          provideDefinition: (doc, pos, tok) =>
            ps.provideDefinition(pos.line, pos.character, getText(doc))
      }) 
      , vscode.languages.registerWorkspaceSymbolProvider({ 
          provideWorkspaceSymbols: (query: string) => 
            ps.getSymbols(query).then(result => result.map(convSymbolInformation))                  
      })
      , vscode.languages.registerDocumentSymbolProvider('purescript', {
          provideDocumentSymbols: (document: vscode.TextDocument, token: vscode.CancellationToken) =>
            ps.getSymbolsForDoc(document).then(result => result.map(convSymbolInformation))
      })
      , vscode.commands.registerCommand("purescript.build", function() {
          const config = vscode.workspace.getConfiguration("purescript");
          ps.build(config.get<string>("buildCommand"), vscode.workspace.rootPath)
            .then(onBuildResult(true))
            .catch(err => {
                console.error(err);
                vscode.window.showErrorMessage("Build error");
            });
      })
      , vscode.languages.registerCodeActionsProvider('purescript', buildProvider)
      , vscode.Disposable.from(new CodeActionCommands())
    );

}
