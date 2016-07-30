import { Diagnostic, Range, DiagnosticSeverity } from 'vscode';

export const mkDiagnostic = (range: Range) => (message: string) => (severity: DiagnosticSeverity) =>
    new Diagnostic(range,message,severity);

export const mkDiagnosticWithInfo = (range: Range) => (message: string) => (severity: DiagnosticSeverity) => (x : any) => {
    var diagnostic = new Diagnostic(range,message,severity);
    (<any>diagnostic).info = x;
    return diagnostic;
};