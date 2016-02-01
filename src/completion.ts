import * as vscode from 'vscode'; 

import { PscIde } from './pscide';
import { getWord } from './utils'; 

interface CompletionResult {
  module: string;
  identifier: string;
  type: string;
}

export class PscCompletionProvider implements  vscode.CompletionItemProvider {
  constructor(private pscIde : PscIde) {}
  
	provideCompletionItems(document: vscode.TextDocument, position: vscode.Position, token: vscode.CancellationToken) {
    const info = getWord(document, position);
    
    return this.pscIde.getCompletion(info.word, info.module).then((result: CompletionResult[]) => {
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