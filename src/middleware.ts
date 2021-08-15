import { Middleware } from "vscode-languageclient";

let _middleware: Middleware = {}

export const middlewareHack: Middleware = {
  didOpen(this, data, next) {
    return _middleware.didOpen ? _middleware.didOpen(data, next) : next(data);
  },
  didChange(this, data, next) {
    return _middleware.didChange ? _middleware.didChange(data, next) : next(data);
  },
  willSave(this, data, next) {
    return _middleware.willSave
      ? _middleware.willSave(data, next) : next(data);
  },
  willSaveWaitUntil(this, data, next) {
    return _middleware.willSaveWaitUntil
      ? _middleware.willSaveWaitUntil(data, next) : next(data);
  },
  didSave(this, data, next) {
    return _middleware.didSave
      ? _middleware.didSave(data, next) : next(data);
  },
  didClose(this, data, next) {
    return _middleware.didClose
      ? _middleware.didClose(data, next) : next(data);
  },
  handleDiagnostics(this, uri, diagnostics, next) {
    return _middleware.handleDiagnostics
      ? _middleware.handleDiagnostics(uri, diagnostics, next) : next(uri, diagnostics);
  },
  provideCompletionItem(this, document, position, context, token, next) {
    return _middleware.provideCompletionItem
      ? _middleware.provideCompletionItem(document, position, context, token, next) : next(document, position, context, token);
  },
  resolveCompletionItem(this, item, token, next) {
    return _middleware.resolveCompletionItem
      ? _middleware.resolveCompletionItem(item, token, next) : next(item, token);
  },
  provideHover(this, document, position, token, next) {
    return _middleware.provideHover
      ? _middleware.provideHover(document, position, token, next) : next(document, position, token);
  },
  provideSignatureHelp(this, document, position, context, token, next) {
    return _middleware.provideSignatureHelp
      ? _middleware.provideSignatureHelp(document, position, context, token, next) : next(document, position, context, token);
  },
  provideDefinition(this, document, position, token, next) {
    return _middleware.provideDefinition
      ? _middleware.provideDefinition(document, position, token, next) : next(document, position, token)
  },
  provideReferences(this, document, position, options, token, next) {
    return _middleware.provideReferences
      ? _middleware.provideReferences(document, position, options, token, next) : next(document, position, options, token)
  },
  provideDocumentHighlights(this, document, position, token, next) {
    return _middleware.provideDocumentHighlights
      ? _middleware.provideDocumentHighlights(document, position, token, next) : next(document, position, token)
  },
  provideDocumentSymbols(this, document, token, next) {
    return _middleware.provideDocumentSymbols
      ? _middleware.provideDocumentSymbols(document, token, next) : next(document, token)
  },
  provideWorkspaceSymbols(this, query, token, next) {
    return _middleware.provideWorkspaceSymbols
      ? _middleware.provideWorkspaceSymbols(query, token, next) : next(query, token)
  },
  provideCodeActions(this, document, range, context, token, next) {
    return _middleware.provideCodeActions
      ? _middleware.provideCodeActions(document, range, context, token, next) : next(document, range, context, token)
  },
  provideCodeLenses(this, document, token, next) {
    return _middleware.provideCodeLenses
      ? _middleware.provideCodeLenses(document, token, next) : next(document, token)
  },
  resolveCodeLens(this, codeLens, token, next) {
    return _middleware.resolveCodeLens
      ? _middleware.resolveCodeLens(codeLens, token, next) : next(codeLens, token)
  },
  provideDocumentFormattingEdits(this, document, options, token, next) {
    return _middleware.provideDocumentFormattingEdits
      ? _middleware.provideDocumentFormattingEdits(document, options, token, next) : next(document, options, token);
  },
  provideDocumentRangeFormattingEdits(this, document, range, options, token, next) {
    return _middleware.provideDocumentRangeFormattingEdits
      ? _middleware.provideDocumentRangeFormattingEdits(document, range, options, token, next) : next(document, range, options, token)
  },
  provideOnTypeFormattingEdits(this, document, position, ch, options, token, next) {
    return _middleware.provideOnTypeFormattingEdits
      ? _middleware.provideOnTypeFormattingEdits(document, position, ch, options, token, next) : next(document, position, ch, options, token)
  },
  provideRenameEdits(this, document, position, newName, token, next) {
    return _middleware.provideRenameEdits
      ? _middleware.provideRenameEdits(document, position, newName, token, next) : next(document, position, newName, token);
  },
  prepareRename(this, document, position, token, next) {
    return _middleware.prepareRename
      ? _middleware.prepareRename(document, position, token, next) : next(document, position, token);
  },
  provideDocumentLinks(this, document, token, next) {
    return _middleware.provideDocumentLinks
      ? _middleware.provideDocumentLinks(document, token, next) : next(document, token)
  },
  resolveDocumentLink(this, link, token, next) {
    return _middleware.resolveDocumentLink
      ? _middleware.resolveDocumentLink(link, token, next) : next(link, token)
  },
  executeCommand(this, command, args, next) {
    return _middleware.executeCommand
      ? _middleware.executeCommand(command, args, next) : next(command, args)
  },
  //
  provideTypeDefinition(this, document, position, token, next) {
    return _middleware.provideTypeDefinition
      ? _middleware.provideTypeDefinition(document, position, token, next) : next(document, position, token);
  },
  //
  provideImplementation(this, document, position, token, next) {
    return _middleware.provideImplementation
      ? _middleware.provideImplementation(document, position, token, next) : next(document, position, token);
  },
  //
  provideDocumentColors(this, document, token, next) {
    return _middleware.provideDocumentColors
      ? _middleware.provideDocumentColors(document, token, next) : next(document, token);
  },
  provideColorPresentations(this, color, context, token, next) {
    return _middleware.provideColorPresentations
      ? _middleware.provideColorPresentations(color, context, token, next) : next(color, context, token);
  },
  //
  provideFoldingRanges(this, document, context, token, next) {
    return _middleware.provideFoldingRanges
      ? _middleware.provideFoldingRanges(document, context, token, next) : next(document, context, token);
  },
  //
  provideDeclaration(this, document, position, token, next) {
    return _middleware.provideDeclaration
      ? _middleware.provideDeclaration(document, position, token, next) : next(document, position, token);
  },
  //
  provideSelectionRanges(this, document, positions, token, next) {
    return _middleware.provideSelectionRanges
      ? _middleware.provideSelectionRanges(document, positions, token, next) : next(document, positions, token);
  },
}

export const setMiddleware = (m: Middleware) => {
  _middleware = m;
}