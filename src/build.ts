import * as vscode from 'vscode'; 
import * as cp from 'child_process';
import { PscIde } from './pscide';

interface PscPosition {
    startLine: number;
    endLine: number;
    startColumn: number;
    endColumn: number;
}
interface PscError {
    moduleName: string;
    errorCode: string;
    message: string;
    filename: string;
    position: PscPosition;
}
interface PscResults {
    warnings: PscError[],
    errors: PscError[]
}

function runPsc() {
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
                        resolve(errors);
                    } catch (e) {
                        reject(e);
                    }
                }
            });
            reject("Unable to parse error output");
                //vscode.window.showErrorMessage("psc-ide exited with code " + code);
        });
    });
}

function toDiagnostic(error : PscError, isError : boolean) : [vscode.Uri, vscode.Diagnostic] {
    var p = error.position;
    var diagnostic = new vscode.Diagnostic(new vscode.Range(p.startLine-1, p.startColumn-1, p.endLine-1, p.endColumn-1), 
        error.message, 
        isError ? vscode.DiagnosticSeverity.Error : vscode.DiagnosticSeverity.Warning);
    diagnostic.code = error.errorCode;
    return [vscode.Uri.file(error.filename), diagnostic];
}

export function build() {
    const diagnosticCollection = vscode.languages.createDiagnosticCollection("purescript");
    
	return runPsc().then((result) => {
        const diagnostics = result.errors.map(e => toDiagnostic(e, true))
            .concat(result.warnings.map(e => toDiagnostic(e, false)))
        
        const map = new Map<vscode.Uri, vscode.Diagnostic[]>();
        diagnostics.forEach(d => {
            const entries = map.get(d[0]) || [];
            entries.push(d[1]);
            map.set(d[0], entries);
        });
        
        diagnosticCollection.set(Array.from(map.entries()));                
    });
}

		