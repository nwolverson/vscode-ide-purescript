import { workspace, WorkspaceConfiguration } from 'vscode';

export const getConfiguration = (section : string) => () => workspace.getConfiguration(section);

export const getValue = (config : WorkspaceConfiguration) => (key: string) => () => config.get(key);

export const rootPath = () => workspace.rootPath;