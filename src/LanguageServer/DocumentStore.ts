import { TextDocuments,  } from 'vscode-languageserver';

export const getDocuments = (documents: TextDocuments) => () => documents.all();

export const getDocument = (documents: TextDocuments) => (uri: string) => () => documents.get(uri);


