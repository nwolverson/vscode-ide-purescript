import * as vscode from 'vscode';
import * as cp from 'child_process';
import { EditorContext } from './editor-context';

interface PscIdeResult {
	resultType : string
	result: any
}

export class PscIde {
	serverProcess : cp.ChildProcess
	path = vscode.workspace.rootPath
	
	constructor(private editorContext : EditorContext) {
		
	}
	
	activate() {
		this.startServer().then(() => {
			global.setTimeout(() => {
				this.editorContext.activate(this);
			}, 100);
		})
	}
	
	startServer() {
		return this.getWorkingDir().then((output: string) => {
			output = output.trim();
			if (output === this.path) {
				vscode.window.showInformationMessage("Found existing psc-ide-server with correct path");
			} else {
          		vscode.window.showErrorMessage(`Found existing psc-ide-server with wrong path: ${output}. Correct, kill or configure a different port, and restart.`);
			}
		}).catch((err) => {
			vscode.window.showInformationMessage('Starting psc-ide-server');
            const config = vscode.workspace.getConfiguration("purescript");
			this.serverProcess = cp.spawn(config.get<string>('pscIdeServerExe'), [], { cwd: this.path });
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
            const config = vscode.workspace.getConfiguration("purescript");
			const proc = cp.spawn(config.get<string>('pscIdeClientExe'), []);
		
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
						console.log(`Command ${JSON.stringify(cmd)} exited with results: ${JSON.stringify(response.result)}`);
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
	
	getLoadedModules() {
		return this.runCmd({ command: "list", params: { type: "module" } });
	}

	getImports(file: string){
    	return this.runCmd({ command: "list", params: { type: "import", file: file } });
	}
	
	getWorkingDir() {
		return this.runCmd({command: "cwd"});
	}

	loadDeps(module: string) {
		if (!module) {
			return Promise.resolve();
		}
		return this.runCmd({
			command: "load",
			params: {
				dependencies: [ module ]
			}
		})
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
		var filters : {filter: string, params: {} }[] = [{
			filter: "prefix",
			params: {
				search: text
			}
		}];
		filters.push(this.modulesFilter(modulePrefix));// if !moduleCompletion
		return this.runCmd({
			command: "complete",
			params: { filters: filters }
		});
	}
	
	modulesFilter(modulePrefix: string) {
		var mods : string[] = [];
		if (modulePrefix) {
			// Prefix may be explicit module or a qualified import
			mods = this.editorContext.getQualifiedModules(modulePrefix);
			if (mods.length === 0) {
				mods = [modulePrefix];
			}
		} else {
			mods = this.editorContext.getUnqualifiedModules();
		}
		return {
			filter: "modules",
			params: {
				modules: mods
			}
		}
	}
  
  	abbrevType(type: string) {
		return type.replace(/(?:\w+\.)+(\w+)/g, "$1");
	}
}
