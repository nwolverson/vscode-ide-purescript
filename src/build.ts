import * as vscode from 'vscode'; 

export interface PscPosition {
    startLine: number;
    endLine: number;
    startColumn: number;
    endColumn: number;
}
export interface PscError {
    moduleName: string;
    errorCode: string;
    message: string;
    filename: string;
    position: PscPosition;
    suggestion?: PscErrorSuggestion
}
export interface PscErrorSuggestion {
    replacement: string
}
export interface PscResults {
    warnings: PscError[];
    errors: PscError[];
}
export interface QuickFix {
    suggest: boolean;
    replacement: string;
}
export interface FileDiagnostic {
    filename: string;
    diagnostic: vscode.Diagnostic;
    quickfix: QuickFix;
}
export interface BuildResult {
    success: boolean;
    diagnostics: FileDiagnostic[];
}

export function pscPositionToRange(p: PscPosition) : vscode.Range {
    return new vscode.Range(p.startLine-1, p.startColumn-1, p.endLine-1, p.endColumn-1)
}
