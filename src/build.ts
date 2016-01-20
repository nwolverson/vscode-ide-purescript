import * as vscode from 'vscode'; 
import * as cp from 'child_process';
import { PscIde } from './pscide';

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
    warnings: PscError[],
    errors: PscError[]
}

function printError(output : vscode.OutputChannel, error : PscError, errorType: string) {
    output.appendLine(`${errorType} in module ${error.moduleName}:`);
    var p = error.position;
    output.appendLine(`at ${error.filename} line ${p.startLine}, column ${p.startColumn} - line ${p.endLine}, column ${p.endColumn}`)
    output.appendLine(error.message);
}

function runPsc(output : vscode.OutputChannel) {
    return new Promise<PscResults>((resolve, reject) => {
        console.log("CWD: " + vscode.workspace.rootPath);
        const proc = cp.spawn("pulp", ["build", "--json-errors"], {
            cwd: vscode.workspace.rootPath 
        });
		
        let result = "";
        let error = "";
        proc.stdout.on('data', (data) => {
            result += data;
        });
        proc.stderr.on('data', (data) => {
            error += data;
        });
        proc.on('error', (err) => {
            vscode.window.showErrorMessage("build error: " + err)
            reject(err);
        });
        proc.on('close', (code) => {
            if (code !== 0) {
                vscode.window.showErrorMessage("Build failed");
            } else {
                vscode.window.showInformationMessage("Build completed");
            }
            error.split('\n').forEach(line => {
                if (line.startsWith('{"warnings":')) {
                    try {
                        const errors : PscResults = JSON.parse(line);
                        errors.errors.forEach(e => printError(output, e, "Error"));
                        errors.warnings.forEach(e => printError(output, e, "Warning"));
                        resolve(errors);
                    } catch (e) {
                        output.appendLine("Error parsing JSON: " + e);
                        reject(e);
                    }
                } else {
                    output.appendLine(line);
                }
            });
            reject("Unable to parse error output");
                //vscode.window.showErrorMessage("psc-ide exited with code " + code);
        });
    });
}

export function pscPositionToRange(p: PscPosition) : vscode.Range {
    return new vscode.Range(p.startLine-1, p.startColumn-1, p.endLine-1, p.endColumn-1)
}

function toDiagnostic(error : PscError, isError : boolean) : [vscode.Uri, vscode.Diagnostic] {
    var diagnostic = new vscode.Diagnostic(pscPositionToRange(error.position), 
        error.message, 
        isError ? vscode.DiagnosticSeverity.Error : vscode.DiagnosticSeverity.Warning);
    diagnostic.code = error.errorCode;
    (<any>diagnostic).error = error
    return [vscode.Uri.file(error.filename), diagnostic];
}

export function build() : Promise<PscResults> {
    const output = vscode.window.createOutputChannel("PureScript build");
    output.clear();
    const diagnosticCollection = vscode.languages.createDiagnosticCollection("purescript");
    
	return runPsc(output).then((result) => {
        const diagnostics = result.errors.map(e => toDiagnostic(e, true))
            .concat(result.warnings.map(e => toDiagnostic(e, false)))
        
        const map = new Map<vscode.Uri, vscode.Diagnostic[]>();
        diagnostics.forEach(d => {
            const entries = map.get(d[0]) || [];
            entries.push(d[1]);
            map.set(d[0], entries);
        });
        
        diagnosticCollection.set(Array.from(map.entries()));
        
        return result;
    });
}

		