import { TextDocument, Range, CodeActionContext, 
    CancellationToken, CodeActionProvider, 
    Command, commands, Disposable, workspace, WorkspaceEdit } 
    from 'vscode';
import { PscError, PscPosition, PscErrorSuggestion, pscPositionToRange, PscResults, QuickFix, FileDiagnostic, BuildResult } from './build';

function replaceSuggestion(fileName : string, range : Range, replacement : string) {
    var doc = workspace.openTextDocument(fileName).then((doc) => 
    {
        var edit = new WorkspaceEdit();
        edit.replace(doc.uri, range, replacement);
        workspace.applyEdit(edit);  
    }).then(null, e => { 
        console.error("Error in replaceSuggestion action: " + e);
    });
}

export class BuildActionProvider implements CodeActionProvider {
    private buildResults : Map<number, FileDiagnostic>;
    
    setBuildResults(result : Map<number, FileDiagnostic>) {
        this.buildResults = result;
    }
    
    provideCodeActions(document: TextDocument, range: Range, context: CodeActionContext, token: CancellationToken)
        : Command[] {
            console.log(`Asked for code actions for range: ${range.start.line}-${range.end.line}`)
           
        return context.diagnostics
            .filter(d => d.range.contains(range))
            .map(d => {
                const code = d.code;
                if (typeof code === "number") {
                    return this.buildResults.get(code);
                } else {
                    return this.buildResults.get(parseInt(code, 10));
                }
            })
            .filter(d => d !== undefined && d.quickfix.suggest)
            .map(d => {
                return ({ 
                    command: "purescript.replaceSuggestion",
                    title: "Apply Suggestion",
                    arguments: [ document.fileName, d.diagnostic.range, d.quickfix.replacement ]
                }); 
            });
    }
}

export class CodeActionCommands {
    commands : Disposable[]
    constructor() {
        this.registerCommands();
    }
    
    registerCommands() {
        this.commands = [ 
            commands.registerCommand("purescript.replaceSuggestion", replaceSuggestion)
        ];
    }
    
    dispose() {
        this.commands.forEach(d => d.dispose());
    }
}
