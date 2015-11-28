# ide-purescript package for VS Code

This package provides editor support for PureScript projects in Visual Studio Code (very much based on the corresponding [atom plugin](https://github.com/nwolverson/atom-ide-purescript). Basic syntax highlighting support is provided by the separate package [language-purescript](https://marketplace.visualstudio.com/items/nwolverson.language-purescript) which should be installed automatically as a dependency. 

This extension relies heavily on the separate tool [psc-ide](https://github.com/kRITZCREEK/psc-ide) (see below).

This package provides:

- [ ] Build and error reporting (TODO)
- [x] Autocompletion
- [x] Type info tooltips

Package should trigger on opening a `.purs` file.

## Installation and General Use

This package relies on having [psc-ide](https://github.com/kRITZCREEK/psc-ide) installed.
For use with PureScript compiler version *0.7.5* you should use [version 0.4.0](https://github.com/kRITZCREEK/psc-ide/releases/tag/0.4.0),
for earlier compiler versions you instead need [0.3.0.0](https://github.com/kRITZCREEK/psc-ide/releases/tag/0.3.0.0).
This runs a server process, `psc-ide-server`, to provide type information, completions,
etc. This package will automatically start `psc-ide-server` in your project
directory (port is configurable) and kill it when closing, if for some reason
you want a longer running server process you should be able to start that before
starting code. *Multiple projects currently not supported!*

For all functions provided by `psc-ide` you will need to build your project first!
Dependencies will automatically be loaded via `dependencies Current.File` as
required.

You *must* install the extension [language-purescript](https://marketplace.visualstudio.com/items/nwolverson.language-purescript)
(should be installed automatically). The package will start on opening a `.purs` file.

## Autocomplete

Provided from [psc-ide](https://github.com/kRITZCREEK/psc-ide). Make sure
your project is built first.

Completions will be sourced from modules imported in the current file.

## Tooltips

Hovering over an identifier will show a tooltip with its type.

This is really stupid, and only cares that you hover over a word regardless of context, you will get some false positives
(eg doesn't see local definitions, just the globals that should be visible in a given module).

## Pursuit lookup

TODO

## PSCI

TODO

## Build

TODO

(I did look at the built in task support, but I think we want explicit build support in this plugin, for flexible error parsing,
particularly when psc starts to produce JSON errors in a future version, as well as easy setup.)