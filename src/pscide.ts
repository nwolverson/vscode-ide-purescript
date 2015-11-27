import * as vscode from 'vscode';
import * as cp from 'child_process';

interface PscIdeResult {
	resultType : string
	result: any
}

export class PscIde {
	serverProcess : cp.ChildProcess
	path = vscode.workspace.rootPath
	
	startServer() {
		this.getWorkingDir().then((output: string) => {
			output = output.trim();
			if (output === this.path) {
				vscode.window.showInformationMessage("Found existing psc-ide-server with correct path");
			} else {
          		vscode.window.showErrorMessage(`Found existing psc-ide-server with wrong path: ${output}. Correct, kill or configure a different port, and restart.`);
			}
		}).catch((err) => {
			vscode.window.showInformationMessage('Starting psc-ide-server');
			this.serverProcess = cp.spawn("psc-ide-server", [], { cwd: this.path });
			this.serverProcess.on('exit', (code) => {
				if (code !== 0) {
					vscode.window.showErrorMessage("Could not start psc-ide-server process. Check the configured port number is valid.");
				}
			})
		})
	}
	
	dispose() {
		if (this.serverProcess) {
			this.serverProcess.kill();
		}
	}
	
	runCmd(cmd : { command: string, params?: Object }) {
		return new Promise<any>((resolve, reject) => {
			const proc = cp.spawn("psc-ide", []);
		
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
	
	getWorkingDir() {
		return this.runCmd({command: "cwd"});
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
	
	getCompletion(text : string, modulePrefix?: string, moduleCompletion?: any) {
		var filters = [{
			filter: "prefix",
			params: {
				search: text
			}
		}];
		//filters.push @modulesFilter(modulePrefix) if !moduleCompletion
		return this.runCmd({
			command: "complete",
			params: { filters: filters }
		});
	}
	
  
  	abbrevType(type: string) {
		return type.replace(/(?:\w+\.)+(\w+)/g, "$1");
	}
	
}
