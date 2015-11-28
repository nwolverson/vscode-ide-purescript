import * as vscode from 'vscode';
import { PscIde } from './pscide';
import { XRegExp } from 'xregexp';

interface Import {
	module: string;
	qualifier: string;
}
export class EditorContext {
	main : string = null
	imports : Import[] = []
	pscIde : PscIde = null
	
	subscriptions: vscode.Disposable[] = []
	
	activate(pscIde : PscIde) {
		this.pscIde = pscIde;
		this.subscriptions.push(
			vscode.window.onDidChangeActiveTextEditor((editor) => this.useEditor(editor)),
			vscode.workspace.onDidSaveTextDocument((document) => this.useDocument(document))
		);
		const editor = vscode.window.activeTextEditor;
		if (editor) {
			this.useEditor(editor);
		}
	}
	
	dispose() {
		this.subscriptions.forEach(d => d.dispose());
	}
	
	useEditor(editor: vscode.TextEditor) {
		this.useDocument(editor.document);
	}
	useDocument(document: vscode.TextDocument) {
		this.pscIde.loadDeps(this.getMainModule(document)).catch(err => {
			console.warn("error loading deps:" + err);
		});
		this.pscIde.getImports(document.fileName).then((imports : Import[]) => {
			this.main = this.getMainModule(document);
			this.imports = imports;
			console.log("Using imports: " + imports.map(i => JSON.stringify(i)));
		}).catch(err => {
			console.warn("error getting imports:" + err);
			this.main = null;
			this.imports = [];
		});
	}
	
	getUnqualifiedModules() {
		var modules = this.imports.filter(imp => !imp.qualifier).map(imp => imp.module);
		if (this.main) {
			modules.push(this.main);
		}
		return modules;
	}
	getQualifiedModules(qualifier: string) {
		return this.imports.filter(imp => imp.qualifier === qualifier).map(imp => imp.module);
	}
	
	getMainModule(document: vscode.TextDocument) {
		const res = XRegExp.exec(document.getText(), /^module\s+([\w.]+)/m)
    	if (res && res.length) {
			return res[1];
		}
	}
}