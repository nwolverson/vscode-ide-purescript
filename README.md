# ide-purescript package for VS Code

This package provides editor support for PureScript projects in Visual Studio Code, similar to the corresponding
 [atom plugin](https://github.com/nwolverson/atom-ide-purescript). Now based on a common
 [PureScript language server](https://github.com/nwolverson/purescript-language-server)! Basic syntax highlighting support
 is provided by the separate package [language-purescript](https://marketplace.visualstudio.com/items/nwolverson.language-purescript) 
 which should be installed automatically as a dependency. 

This package provides:

- [x] Build and error reporting
- [x] Quick-fix support for certain warnings
- [x] Autocompletion
- [x] Type info tooltips
- [x] Go to symbol
- [x] Go to definition

Package should trigger on opening a `.purs` file.

## Installation and General Use

This package makes use of the [`purs ide server`](https://github.com/purescript/purescript/tree/master/psc-ide) (previously `psc-ide`) for most functionality, with `purs compile` (by default via `pulp`) for the explicit
build command. All this is via a Language Server Protocol implementation, [purescript-language-server](https://github.com/nwolverson/purescript-language-server).

This package will launch a `purescript-language-server` process, which will automatically (but this is configurable) start `purs ide server` in your project directory and kill it when closing. Start/stop and restart commands are provided for the IDE server in case required (eg after changing config or updating compiler version).

Multi-root workspaces should be supported via a multiple language server approach.

For all functions provided by the IDE server you will need to build your project first!

The extension [language-purescript](https://marketplace.visualstudio.com/items/nwolverson.language-purescript)
is required but should be installed automatically. The package will start on opening a `.purs` file.

### Suggested extensions

See [input-assist](https://github.com/freebroccolo/vscode-input-assist) for Unicode input assistance
on autocomplete which is known to work with this extension, alternatively [unicode-latex](https://github.com/ojsheikh/unicode-latex)
which offers similar LaTeX based input vi a lookup command.

### Key bindings

The only key binding supplied out of the box is Shift+Ctrl+B (or Shift+Cmd+B) for the full "Build" command. Although this is only enabled inside PureScript-language text editors, it does conflict with the built-in Build command. This can be edited, and other keybinds added, in the VS Code Keyboard Shortcuts preferences.

## Build

### With Pulp (default)

'PureScript Build' command will build your project using the command line `pulp build -- --json-errors`.
Version 0.8.0+ of the PureScript compiler is required, as well as version 10.0.0 of `pulp` (with earlier versions remove `--`).

For `pulp` with `psc-package`, add the following configuration to your `settings.json`:
```
{
  "purescript.addNpmPath": true,
  "purescript.buildCommand": "pulp --psc-package build -- --json-errors"
}
```

### With Spago

For `spago` with `psc-package`, add the following configuration to your `settings.json`:
```
{
  "purescript.addSpagoSources": true,
  "purescript.addNpmPath": true,
  "purescript.buildCommand": "spago build -u --json-errors"
}
```

Be sure to `Restart/Reconnect purs IDE server` following such changes.

Error suggestions are provided for some compiler errors, try alt/cmd and `.`.

## Autocomplete

Provided from [`purs ide server`](https://github.com/purescript/purescript/tree/master/psc-ide). Make sure
your project is built first.

Completions will be sourced from modules imported in the current file.

## Tooltips

Hovering over an identifier will show a tooltip with its type.

This is really stupid, and only cares that you hover over a word regardless of context, you will get some false positives
(eg doesn't see local definitions, just the globals that should be visible in a given module).

Hovering over a qualifier of a qualified identifier will show the associated module name.

## Pursuit lookup

Commands "Search Pursuit" and "Search Pursuit Modules" are available to search for identifiers or modules/packages on Pursuit.

## PSCI

No particular support. Suggest you open a PSCI in the integrated terminal.
