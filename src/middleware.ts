import { Middleware } from "vscode-languageclient";

let _middlewareStore: Array<Middleware> = []

type FnKeys<O> = { [K in keyof O]: O[K] extends Function ? true : never }
export const middleware: Middleware = {};

const keys: FnKeys<Middleware> = {
  didOpen: true,
  didChange: true,
  willSave: true,
  willSaveWaitUntil: true,
  didSave: true,
  didClose: true,
  handleDiagnostics: true,
  provideCompletionItem: true,
  resolveCompletionItem: true,
  provideHover: true,
  provideSignatureHelp: true,
  provideDefinition: true,
  provideReferences: true,
  provideDocumentHighlights: true,
  provideDocumentSymbols: true,
  provideWorkspaceSymbols: true,
  provideCodeActions: true,
  provideCodeLenses: true,
  resolveCodeLens: true,
  provideDocumentFormattingEdits: true,
  provideDocumentRangeFormattingEdits: true,
  provideOnTypeFormattingEdits: true,
  provideRenameEdits: true,
  prepareRename: true,
  provideDocumentLinks: true,
  resolveDocumentLink: true,
  executeCommand: true,
  //
  provideTypeDefinition: true,
  //
  provideImplementation: true,
  //
  provideDocumentColors: true,
  provideColorPresentations: true,
  //
  provideFoldingRanges: true,
  //
  provideDeclaration: true,
  //
  provideSelectionRanges: true
};

Object.keys(keys).forEach((key) => {
  middleware[key] = (...params) => {
    const next = params.pop();

    const mws = _middlewareStore
      .filter((mw) => !!mw[key])

    const run = mws.reduceRight((nxtFn, mw) => {
      return (...args) => (mw[key] as Function)(...args, nxtFn);
    }, next);

    return run(...params);
  };
});

export const registerMiddleware = (m: Middleware) => {
  _middlewareStore.push(m);
}

export const unregisterMiddleware = (m: Middleware) => {
  _middlewareStore = _middlewareStore.filter(i => i !== m);
}
