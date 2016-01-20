import { TextDocument, Range, CodeActionContext, 
    CancellationToken, CodeActionProvider, 
    Command, commands, Disposable, workspace, WorkspaceEdit } 
    from 'vscode';
import { PscError, PscPosition, PscErrorSuggestion, pscPositionToRange, PscResults } from './build';

function replaceSuggestion(fileName : string, r : PscPosition, replacement : string) {
    var range = pscPositionToRange(r);
    var doc = workspace.openTextDocument(fileName).then((doc) => 
    {
        var edit = new WorkspaceEdit();
        edit.replace(doc.uri, range, replacement);
        workspace.applyEdit(edit);  
    }).then(null, e => { 
        console.error("Error in replaceSuggestion action: " + e);
    });
}

interface SimpleRange {
    startRow: number,
    startCol: number,
    endRow: number,
    endCol: number
}

function toSimpleRange(r: Range) : SimpleRange {
    return { 
        startRow: r.start.line,
        startCol: r.start.character,
        endRow: r.end.line,
        endCol: r.end.character
    }
}
function fromSimpleRange(r: SimpleRange) : Range {
    return new Range(r.startRow, r.startCol, r.endRow, r.endCol);
}

export class BuildActionProvider implements CodeActionProvider {
    buildResults : PscError[] = [];
    setBuildResults(result : PscResults) {
        this.buildResults = result.errors.concat(result.warnings);
    }
    
    provideCodeActions(document: TextDocument, range: Range, context: CodeActionContext, token: CancellationToken)
        : Command[] {
            console.log(`Asked for code actions for range: ${range.start.line}-${range.end.line}`)
        var res = this.buildResults
            .filter(d => pscPositionToRange(d.position).contains(range))
            .map(d => {
                if (d.suggestion !== null) {
                    return { 
                        command: "purescript.replaceSuggestion",
                        title: "Apply Suggestion",
                        arguments: [ document.fileName, d.position, d.suggestion.replacement ]
                    };
                }
            })
            .filter(x => x != null);
        console.log("Returning: " + res);
        return res;
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
