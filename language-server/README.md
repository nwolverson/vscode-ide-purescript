# PureScript language server

Node-based Language Server Protocol server for PureScript based on the PureScript IDE server
(aka psc-ide / `purs ide server`). Used as the [vscode plugin](https://github.com/nwolverson/vscode-ide-purescript)
backend but should be compatible with other Language Server Client implementations.

The language server is a wrapper around the IDE server included as part of the compiler distribution,
providing editing assistance and build features according to support available. This means that
the server will start its own `purs ide server` instance to talk to for the project directory it is started
in.

## Features

- Completion provider
- Definition provider
- Document & workspace symbol providers
- Hover provider
- Code action provider 
  - Compiler fix suggestions for imports/missing types
- Build on save (via IDE server "fast rebuild" facility, certain limitations apply)
  - Provides diagnostics
- Commands
  - Build (full build via `purs compile` / configured build command) - provides diagnostics
  - Case split
  - Add clause
  - Replace suggestion
  - Add completion import
  - Start IDE server
  - Stop IDE server
  - Restart IDE server

## Development

See [vscode plugin](https://github.com/nwolverson/vscode-ide-purescript) repo. Common code via
[purescript-ide-purescript-core](https://github.com/nwolverson/purescript-ide-purescript-core).