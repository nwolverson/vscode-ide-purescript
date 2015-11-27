import * as vscode from 'vscode';
import * as cp from 'child_process';

interface PscIdeResult {
	resultType : string
	result: any
}

export class PscIde {
	startServer() {
		// // vscode.window.showInformationMessage('Starting psc-ide');
		
		// // this.proc = cp.spawn("psc-ide", [], { cwd: path });
		
		// this.proc.stderr.on('data', (data) => {
			
		// });
	}
	
	runCmd(cmd : { command: string, params?: Object }) {
		const path = vscode.workspace.rootPath;
		return new Promise<any>((resolve, reject) => {
			const proc = cp.spawn("psc-ide", [], { cwd: path });
		
			let result = "";
			proc.stdout.on('data', (data) => {
				result += data;
			});
			proc.on('error', (err) => {
				vscode.window.showErrorMessage("psc-ide error: " + err)
				reject(err);
			});
			proc.on('close', (code) => {
				if (code === 0) {
					var response : PscIdeResult = JSON.parse(result);
					if (response.resultType === "success") {
						resolve(response.result);
					} else {
						reject(response.result);
					}
				} else {
					vscode.window.showErrorMessage("psc-ide exited with code " + code);
					reject(code);
				}
			});
			proc.stdin.write(JSON.stringify(cmd) + "\n");
		});
	}
	
	getType(text: string, modulePrefix: string) {
		return this.runCmd({ 
			command: "type",
			params: {
				search: text,
				filters: []
			}
		}).then((result) => {
			if (result.length > 0) {
				return this.abbrevType(result[0].type);
			} else {
				return "";
			}
		}).catch(() => "");
	}
  
  	abbrevType(type: string) {
		return type.replace(/(?:\w+\.)+(\w+)/g, "$1");
	}
	
}
