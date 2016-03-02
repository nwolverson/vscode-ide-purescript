# ide-purescript package for VS Code

This package provides editor support for PureScript projects in Visual Studio Code (very much based on the corresponding [atom plugin](https://github.com/nwolverson/atom-ide-purescript). Basic syntax highlighting support is provided by the separate package [language-purescript](https://marketplace.visualstudio.com/items/nwolverson.language-purescript) which should be installed automatically as a dependency. 

This extension relies heavily on the separate tool [psc-ide](https://github.com/kRITZCREEK/psc-ide) (see below).

This package provides:

- [x] Build and error reporting
- [x] Autocompletion
- [x] Type info tooltips

Package should trigger on opening a `.purs` file.

## Installation and General Use

This package relies on having [psc-ide](https://github.com/kRITZCREEK/psc-ide) installed.
For use with PureScript compiler version *0.8.0* you should use [version 0.6.0](https://github.com/kRITZCREEK/psc-ide/releases/tag/0.6.0),
for earlier compiler versions consult the `psc-ide` documentation.
This runs a server process, `psc-ide-server`, to provide type information, completions,
etc. This package will automatically start `psc-ide-server` in your project
directory (port is configurable) and kill it when closing, if for some reason
you want a longer running server process you should be able to start that before
starting code. *Multiple projects currently not supported!*

For all functions provided by `psc-ide` you will need to build your project first!
Dependencies will automatically be loaded via `dependencies Current.File` as
required.

The extension [language-purescript](https://marketplace.visualstudio.com/items/nwolverson.language-purescript)
is required but should be installed automatically. The package will start on opening a `.purs` file.

## Build

'PureScript Build' command will build your project using the command line `pulp build --no-psa --json-errors`.
Version 0.8.0 of the PureScript compiler is required, as well as version 8.0.0 of `pulp`.

Error suggestions are provided for some compiler errors, try alt/cmd and `.`.

## Autocomplete

Provided from [psc-ide](https://github.com/kRITZCREEK/psc-ide). Make sure
your project is built first.

Completions will be sourced from modules imported in the current file.

## Tooltips

Hovering over an identifier will show a tooltip with its type.

This is really stupid, and only cares that you hover over a word regardless of context, you will get some false positives
(eg doesn't see local definitions, just the globals that should be visible in a given module).

## Settings

Settings available via user/workspace settings:

```
    "purescript.pscIdeClientExe": "psc-ide-client",
    "purescript.pscIdeServerExe": "psc-ide-server"
```

## Pursuit lookup

TODO

## PSCI

TODO
