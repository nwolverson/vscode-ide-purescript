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

Package should trigger on opening a `.purs` file.

## Installation and General Use

This package relies on having [psc-ide](https://github.com/kRITZCREEK/psc-ide) installed.
As of PureScript compiler version *0.8.2* this is now bundled with the compiler, and things
should "just work"; for earlier compiler versions consult the [`psc-ide` documentation](https://github.com/kRITZCREEK/psc-ide).
This runs a server process, `psc-ide-server`, to provide type information, completions,
etc. This package will automatically start `psc-ide-server` in your project
directory (port is configurable) and kill it when closing, if for some reason
you want a longer running server process you should be able to start that before
starting code. *Multiple projects currently not supported!* `psc-ide-client` is not used,
communication is via direct socket connection.

For all functions provided by `psc-ide` you will need to build your project first!
Dependencies will automatically be loaded via `dependencies Current.File` as
required.

The extension [language-purescript](https://marketplace.visualstudio.com/items/nwolverson.language-purescript)
is required but should be installed automatically. The package will start on opening a `.purs` file.

## Build

'PureScript Build' command will build your project using the command line `pulp build --no-psa --json-errors`.
Version 0.8.0+ of the PureScript compiler is required, as well as version 8.0.0 of `pulp` (for the `--no-psa` flag...).

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
{
	// Location of psc-ide server executable (resolved wrt PATH)
	"purescript.pscIdeServerExe": "psc-ide-server",

	// Port to use for psc-ide
	"purescript.pscIdePort": 4242,

	// Build command to use with arguments. Not passed to shell. eg `pulp build --json-errors`
	"purescript.buildCommand": "pulp build --no-psa --json-errors"
}
```

## Pursuit lookup

TODO

## PSCI

TODO
