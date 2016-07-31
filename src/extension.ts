import * as vscode from 'vscode';

import { BuildActionProvider, CodeActionCommands } from './codeActions';
import { PscError, PscPosition, PscErrorSuggestion, PscResults, QuickFix, FileDiagnostic, BuildResult } from './build';

const getText = doc => (a,b,c,d) => doc.getText(new vscode.Range(new vscode.Position(a,b), new vscode.Position(c,d)));

export function activate(context: vscode.ExtensionContext) {
    const ps = require('./bundle')();
    const config = vscode.workspace.getConfiguration("purescript");

    const useDoc = (doc : vscode.TextDocument) =>
        ps.updateFile(doc.fileName, doc.getText());

    ps.activate(config.get<string>('pscIdeServerExe'), config.get<number>('pscIdePort'), vscode.workspace.rootPath)
        .then(() => {
            if (vscode.window.activeTextEditor) {
                useDoc(vscode.window.activeTextEditor.document)
            }
        });


    const diagnosticCollection = vscode.languages.createDiagnosticCollection("purescript");
    const buildProvider = new BuildActionProvider();
    const onBuildResult = (notifySuccess : boolean) =>  (res : BuildResult) => {
        if (res.success) {
            if (notifySuccess) {
                vscode.window.showInformationMessage("Build success!");
            }
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
                ps.quickBuild(doc.fileName).then(onBuildResult(false));
            }
            useDoc(doc);
          }
        })
      , vscode.languages.registerHoverProvider('purescript', {
        provideHover: (doc, pos, tok) =>
            ps.getTooltips(pos.line, pos.character, getText(doc))
                .then(result => result !== null ? new vscode.Hover(result) : null)
        })
      , vscode.languages.registerCompletionItemProvider('purescript', {
            provideCompletionItems: (doc, pos, _) => ps.getCompletions(pos.line, pos.character, getText(doc)).
                then(result => result.map(it => {
                    const item = new vscode.CompletionItem(it.identifier);
                    item.detail = it.type;
                    if (/^[A-Z]/.test(it.identifier)) {
                        item.kind = vscode.CompletionItemKind.Class;
                    } else if (/->/.test(it.type)) {
                        item.kind = vscode.CompletionItemKind.Function;
                    } else {
                        item.kind = vscode.CompletionItemKind.Value;
                    }

                    return item;
                }))
        })
      , vscode.languages.registerDefinitionProvider('purescript', {
          provideDefinition: (doc, pos, tok) =>
            ps.provideDefinition(pos.line, pos.character, getText(doc))
      }) 
      , vscode.commands.registerCommand("purescript.build", function() {
          const config = vscode.workspace.getConfiguration("purescript");
          ps.build(config.get<string>("buildCommand"), vscode.workspace.rootPath).then(onBuildResult(true));
      })
      , vscode.languages.registerCodeActionsProvider('purescript', buildProvider)
      , vscode.Disposable.from(new CodeActionCommands())
    );

}
