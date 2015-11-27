import * as vscode from 'vscode'; 

import { PscIde } from './pscide';

interface CompletionResult {
  module: string;
  identifier: string;
  type: string;
}

export class PscCompletionProvider implements  vscode.CompletionItemProvider {
  pscIde = new PscIde();
  
	provideCompletionItems(document: vscode.TextDocument, position: vscode.Position, token: vscode.CancellationToken) {
    const wordRange = document.getWordRangeAtPosition(position);
		const word = document.getText(wordRange);
    
    return this.pscIde.getCompletion(word).then((result: CompletionResult[]) => {
      return result.map((c) => {
        var item = new vscode.CompletionItem(c.identifier);
        item.detail = c.type;
        if (c.type === "module") {
          item.kind = vscode.CompletionItemKind.Module;
        } else if (/^[A-Z]/.test(c.identifier)) {
          item.kind = vscode.CompletionItemKind.Class;
        } else if (/->/.test(c.type)) {
          item.kind = vscode.CompletionItemKind.Function;
          
        } else {
          item.kind = vscode.CompletionItemKind.Value;
        }
        return item;
      });
    });
	}
}