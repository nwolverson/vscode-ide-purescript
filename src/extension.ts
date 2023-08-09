import { commands, ExtensionContext, FileType, OutputChannel, TextDocument, Uri, window, workspace, WorkspaceFolder } from 'vscode';
import { CloseAction, ErrorAction, ExecuteCommandRequest, LanguageClient, LanguageClientOptions, RevealOutputChannelOn, ServerOptions, TransportKind } from 'vscode-languageclient/node';
import { setDiagnosticsBegin, setDiagnosticsEnd, setCleanBegin, setCleanEnd, diagnosticsBegin, diagnosticsEnd, cleanBegin, cleanEnd } from './notifications';
import { registerMiddleware, unregisterMiddleware, middleware } from './middleware';
import * as path from 'path';
type ExtensionCommands = { [cmd: string]: (args: any[]) => void };

const clients: Map<string, LanguageClient> = new Map();
const commandCode: Map<string, ExtensionCommands> = new Map();

export function activate(context: ExtensionContext) {
  const activatePS = require('../../output/Main').main;

  // const module = require.resolve('purescript-language-server');

  const module = path.join(context.extensionPath, 'dist', 'server.js');

  const opts = { module, transport: TransportKind.ipc };
  const serverOptions: ServerOptions =
  {
    run: opts,
    debug: {
      ...opts, options: {
        execArgv: [
          "--nolazy",
          "--inspect=6009"
        ]
      }
    }
  }
  const output = window.createOutputChannel("IDE PureScript");
  // Options to control the language client
  const clientOptions = (folder: Uri): LanguageClientOptions => ({

    // Register for PureScript and JavaScript documents in the given root folder
    documentSelector: [
      { scheme: 'file', language: 'purescript', pattern: `${folder.fsPath}/**/*` },
      { scheme: 'file', language: 'javascript', pattern: `${folder.fsPath}/**/*` },
    ],
    workspaceFolder: {
      uri: folder,
      name: "",
      index: 0
    },
    synchronize: {
      configurationSection: 'purescript',
      fileEvents: [
        workspace.createFileSystemWatcher('**/*.purs'),
        workspace.createFileSystemWatcher('**/*.js'),
      ]
    },
    outputChannel: output,
    revealOutputChannelOn: RevealOutputChannelOn.Never,
    errorHandler: {
      error: (e, m, c) => { console.error(e, m, c); return { action: ErrorAction.Continue } },
      closed: () => ({ action: CloseAction.DoNotRestart })
    },
    initializationOptions: {
      executeCommandProvider: false
    },
    middleware
  });

  let commandNames: string[] = [
    "caseSplit-explicit",
    "addClause-explicit",
    "addCompletionImport",
    "addModuleImport",
    "replaceSuggestion",
    "replaceAllSuggestions",
    "build",
    "clean",
    "typedHole-explicit",
    "startPscIde",
    "stopPscIde",
    "restartPscIde",
    "getAvailableModules",
    "search",
    "fixTypo",
    "sortImports"
  ].map(x => `purescript.${x}`);

  const getProjectRootForDocument = async (doc: TextDocument): Promise<Uri | null> => {
    if (doc.languageId === 'purescript' && doc.uri.scheme === 'file') {
      return getProjectRoot(output, doc.uri)
    }
    return null
  }

  commandNames.forEach(command => {
    commands.registerTextEditorCommand(command, async (ed, edit, ...args) => {
      const projectRoot = await getProjectRootForDocument(ed.document);
      if (!projectRoot) { return; }
      const lc = clients.get(projectRoot.fsPath);
      if (!lc) {
        output.appendLine("Didn't find language client for " + ed.document.uri);
        return;
      }
      lc.sendRequest(ExecuteCommandRequest.type, { command, arguments: args });
    });
  })

  const extensionCmd = (cmdName: string) => async (ed, edit, ...args) => {
    const projectRoot = await getProjectRootForDocument(ed.document);
    if (!projectRoot) { return; }
    const cmds = commandCode.get(projectRoot.fsPath);
    if (!cmds) {
      output.appendLine("Didn't find language client for " + ed.document.uri);
      return;
    }
    cmds[cmdName](args);
  }

  async function addClient(folder: Uri) {
    output.appendLine(`Add client for ${folder.fsPath}`);

    if (!clients.has(folder.fsPath)) {
      try {
        output.appendLine("Launching new language client for " + folder.fsPath);
        const client = new LanguageClient('purescript', 'IDE PureScript', serverOptions, clientOptions(folder));

        client.onReady().then(async () => {
          output.appendLine("Activated lc for " + folder.fsPath);
          const cmds: ExtensionCommands = activatePS({ diagnosticsBegin, diagnosticsEnd, cleanBegin, cleanEnd }, client);
          const cmdNames = await commands.getCommands();
          commandCode.set(folder.fsPath, cmds);
          Promise.all(Object.keys(cmds).map(async cmd => {
            if (cmdNames.indexOf(cmd) === -1) {
              commands.registerTextEditorCommand(cmd, extensionCmd(cmd));
            }
          }));
        }).catch(err => output.appendLine(err));

        client.start();
        clients.set(folder.fsPath, client);
      } catch (e) {
        output.appendLine(e);
      }
    }
  }

  async function didOpenTextDocument(document: TextDocument) {
    const folder = await getProjectRootForDocument(document)
    if (!folder) {
      output.appendLine("Didn't find workspace folder for " + document.uri);
      return;
    }
    addClient(folder);
  }

  workspace.onDidOpenTextDocument(didOpenTextDocument);
  workspace.textDocuments.forEach(didOpenTextDocument);
  workspace.onDidChangeWorkspaceFolders((event) => {
    for (const folder of event.removed) {
      const client = clients.get(folder.uri.fsPath);
      if (client) {
        clients.delete(folder.uri.fsPath);
        client.stop();
      }
    }
  });

  if (clients.size == 0) {
    output.appendLine("Open a PureScript file to start language server.");
  }
  return { registerMiddleware, unregisterMiddleware, setDiagnosticsBegin, setDiagnosticsEnd, setCleanBegin, setCleanEnd }
}


export function deactivate(): Thenable<void> {
  let promises: Thenable<void>[] = [];
  for (let client of Array.from(clients.values())) {
    promises.push(client.stop());
  }
  return Promise.all(promises).then(() => undefined);
}


async function getProjectRoot(output: OutputChannel, fileUri: Uri) {
  const root = await getProjectRootRec(fileUri);
  if (root) {
    output.appendLine("Found project root at " + root)
    return root
  } else {
    output.appendLine("No project root found. Defaulting to workspace root.")
    return workspace.getWorkspaceFolder(fileUri).uri
  }
}

async function getProjectRootRec(currentUri: Uri): Promise<Uri | null> {
  // Continue with parent dir if file is in a node_modules or .spago folder
  switch (true) {
    case currentUri.fsPath.includes(".spago"): {
      const parent = path.dirname(currentUri.fsPath.split(".spago")[0])
      return getProjectRootRec(Uri.file(parent))
    }
    case currentUri.fsPath.includes("node_modules"): {
      const parent = path.dirname(currentUri.fsPath.split("node_modules")[0])
      return getProjectRootRec(Uri.file(parent))
    }
  }

  // Get dir of file
  const dir = path.dirname(currentUri.fsPath)

  // Create uri for dir 
  const uri = Uri.file(dir)
  const files = await workspace.fs.readDirectory(uri);

  // Iterate over files looking for spago
  for (const [file, fileType] of files) {
    switch (file) {
      case "spago.dhall":
      case "spago.yml":
      case "spago.yaml":
        return uri
    }
  }

  // Use workspace root as abort condition
  const workspaceFolder = workspace.getWorkspaceFolder(currentUri)
  if (dir === workspaceFolder.uri.fsPath) {
    return null
  } else {
    // If none found, try with next parent folder
    return getProjectRootRec(uri)
  }
}