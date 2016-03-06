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
        
    const buildProvider = new BuildActionProvider();
    context.subscriptions.push(
        vscode.window.onDidChangeActiveTextEditor((editor) => useDoc(editor.document))
      , vscode.workspace.onDidSaveTextDocument(useDoc)
      , vscode.languages.registerHoverProvider('purescript', { 
        provideHover: (doc, pos, tok) => 
            ps.getTooltips(pos.line, pos.character, getText(doc))
                .then(result => result.length ? new vscode.Hover(result) : null)
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
      , vscode.commands.registerCommand("purescript.build", function() {
          const config = vscode.workspace.getConfiguration("purescript");
          ps.build(config.get<string>("buildCommand"), vscode.workspace.rootPath).then((res : BuildResult) => {
              if (res.success) {
                  vscode.window.showInformationMessage("Build success!");
                  let code = 0;
                  const map = new Map<vscode.Uri, vscode.Diagnostic[]>();
                  
                  const actionMap = new Map<number, FileDiagnostic>();
                  res.diagnostics.forEach(d => {
                      ++code;
                      d.diagnostic.code = code;
                      actionMap.set(code, d);
                      const uri = vscode.Uri.file(d.filename);
                      const entries = map.get(uri) || [];
                      entries.push(d.diagnostic);
                      map.set(uri, entries);
                  });
                  const diagnosticCollection = vscode.languages.createDiagnosticCollection("purescript");
                  diagnosticCollection.set(Array.from(map.entries()));
                  
                  buildProvider.setBuildResults(actionMap);
              } else {
                  vscode.window.showErrorMessage("Build error :(");
              }
              console.info(res);
          });
      })
      , vscode.languages.registerCodeActionsProvider('purescript', buildProvider)
      , vscode.Disposable.from(new CodeActionCommands())
    );
      
}