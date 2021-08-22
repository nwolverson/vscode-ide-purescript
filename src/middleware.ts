import { Middleware } from "vscode-languageclient";

let _middleware: Middleware = {}
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
  middleware[key] = (...args) => {
    const next = args.pop();
    const fn = _middleware[key] as Function;
    return fn ? fn(...args, next) : next(args);
  }
});

export const setMiddleware = (m: Middleware) => {
  _middleware = m;
}
