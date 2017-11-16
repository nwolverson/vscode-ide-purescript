# ide-purescript package for VS Code

This package provides editor support for PureScript projects in Visual Studio Code, similar to the corresponding
 [atom plugin](https://github.com/nwolverson/atom-ide-purescript). Now based on a common
 [PureScript based core](https://github.com/nwolverson/purescript-ide-purescript-core)! Basic syntax highlighting support
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

This package will automatically start `purs ide server` in your project
directory (port is configurable) and kill it when closing, if for some reason
you want a longer running server process you should be able to start that before
starting `code`. *Multiple projects currently not supported!* `purs ide client` is not used,
communication is via direct socket connection.

For all functions provided by the IDE server you will need to build your project first!

The extension [language-purescript](https://marketplace.visualstudio.com/items/nwolverson.language-purescript)
is required but should be installed automatically. The package will start on opening a `.purs` file.

### Suggested extensions

See [input-assist](https://github.com/freebroccolo/vscode-input-assist) for Unicode input assistance
on autocomplete which is known to work with this extension, alternatively [unicode-latex](https://github.com/ojsheikh/unicode-latex)
which offers similar LaTeX based input vi a lookup command.

## Build

'PureScript Build' command will build your project using the command line `pulp build --no-psa --json-errors`.
Version 0.8.0+ of the PureScript compiler is required, as well as version 8.0.0 of `pulp` (for the `--no-psa` flag...).

Error suggestions are provided for some compiler errors, try alt/cmd and `.`.

## Autocomplete

Provided from [`purs ide server`](https://github.com/purescript/purescript/tree/master/psc-ide). Make sure
your project is built first.

Completions will be sourced from modules imported in the current file.

## Tooltips

Hovering over an identifier will show a tooltip with its type.

This is really stupid, and only cares that you hover over a word regardless of context, you will get some false positives
(eg doesn't see local definitions, just the globals that should be visible in a given module).

## Pursuit lookup

TODO - make this work again.

## PSCI

No particular support. Suggest you open a PSCI in the integrated terminal.
