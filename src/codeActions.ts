import { TextDocument, Range, CodeActionContext, 
    CancellationToken, CodeActionProvider, 
    Command, commands, Disposable, workspace, WorkspaceEdit } 
    from 'vscode';
import { PscError, PscPosition, PscErrorSuggestion, pscPositionToRange, PscResults, QuickFix, FileDiagnostic, BuildResult } from './build';

function replaceSuggestion(fileName : string, range : Range, replacement : string, suggestRange : Range) {
    console.log("Replacing", range, suggestRange);
    var doc = workspace.openTextDocument(fileName).then((doc) => 
    {
        const trailingNewline = /\n\s+$/.test(replacement);
        const endText = doc.getText(new Range(suggestRange.end, suggestRange.end.translate(0, 10)));
        const addNewline = trailingNewline && !(endText.length == 0)
        var edit = new WorkspaceEdit();
        // TODO: This will break after edits have happened
        edit.replace(doc.uri, suggestRange, replacement.trim() + (addNewline ? "\n" : ""));
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
                    arguments: [ document.fileName, d.diagnostic.range, d.quickfix.replacement, d.quickfix.range ]
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
