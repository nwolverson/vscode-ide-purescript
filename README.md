# ide-purescript package for VS Code

This package provides editor support for PureScript projects in Visual Studio Code, similar to the corresponding
 [atom plugin](https://github.com/nwolverson/atom-ide-purescript). Now based on a common
 [PureScript language server](https://github.com/nwolverson/purescript-language-server)! 

This package provides:

-  [x] [Autocompletion](#autocomplete)
-  [x] Quick-fix support for certain warnings
-  [x] [Build and error reporting](#build-and-error-reporting)
-  [x] [Case split](#case-split)
-  [x] [Add clause](#add-clause)
-  [x] [Tooltips](#tooltips)
-  [x] [Go to symbol](#go-to-symbol)
-  [x] [Go to definitions](#go-to-definitions)
-  [x] [Pursuit lookup](#pursuit-lookup)
-  [x] [PSCI](#psci)

The extension [language-purescript](https://marketplace.visualstudio.com/items/nwolverson.language-purescript) provides basic syntax highlighting support - it is required but should be installed automatically as a dependency. This package will start on opening a `.purs` file, and automatically trigger a rebuild on saving a `.purs` file.

## Installation and General Use

This package makes use of the [`purs ide server`](https://github.com/purescript/purescript/tree/master/psc-ide) (previously `psc-ide`) for most functionality, with `purs compile` (by default via `pulp`) for the explicit
build command. All this is via a Language Server Protocol implementation, [purescript-language-server](https://github.com/nwolverson/purescript-language-server). Multi-root workspaces should be supported via a multiple language server approach.

This package will launch a `purescript-language-server` process, which will automatically (but this is configurable) start `purs ide server` in your project directory and kill it when closing. Start/stop and restart commands are provided for the IDE server in case required (eg after changing config or updating compiler version).

For all functions provided by the IDE server you will need to build your project first! This can either be via the built-in
build command, or via an external tool - but if you do build externally, you should be sure to `Restart/Reconnect purs IDE server` (accessed through `CTRL+SHIFT+P`/`CMD+SHIFT+P`) afterwards, or the IDE server will not be able to pick up any changes.

If you open CTRL+SHIFT+P, then type 'purescript', you will get the following menu.

![command-menu](https://user-images.githubusercontent.com/1215420/89945576-3ab68a00-dc2a-11ea-9486-93db4ef2741a.png)

You can configure building with `pulp` (optionally with `psc-package`) or `spago` by following the configuration steps below, after which you should also `Restart/Reconnect purs IDE server`.

### With Pulp (default)

`PureScript: Build` command will build your project using the command line `pulp build -- --json-errors`.
Version 0.8.0+ of the PureScript compiler is required, as well as version 10.0.0 of `pulp` (with earlier versions remove `--`).

For `pulp` with `psc-package`, add the following configuration to your `settings.json`:
```
{
  "purescript.addNpmPath": true,
  "purescript.buildCommand": "pulp --psc-package build -- --json-errors"
}
```

### With Spago

Note that `--` was replaced by `--purs-args` in spago version `0.10.0.0`.

For `spago` with `psc-package`, add the following configuration to your `settings.json`:
```
{
  "purescript.addSpagoSources": true,
  "purescript.addNpmPath": true,
  "purescript.buildCommand": "spago build --purs-args --json-errors"
}
```

### Suggested extensions

See [input-assist](https://github.com/freebroccolo/vscode-input-assist) for Unicode input assistance
on autocomplete which is known to work with this extension, alternatively [unicode-latex](https://github.com/ojsheikh/unicode-latex)
which offers similar LaTeX based input vi a lookup command.

### Key bindings

The only key binding supplied out of the box is Shift+Ctrl+B (or Shift+Cmd+B) for the full "Build" command. Although this is only enabled inside PureScript-language text editors, it does conflict with the built-in Build command. This can be edited, and other keybinds added, in the VS Code Keyboard Shortcuts preferences.

The following default vscode bindings are helpful for processing build errors:
* `F8` cycles through errors.
* `CTRL + .` or `CMD + .` shows suggested fixes. The compiler sometimes provides these suggestions.

We will suggest you to add keyboard bindings for commands that you use frequently, which you can do through the menu item `File > Properties > Keyboard Shortcuts`.

## Autocomplete

Provided from [`purs ide server`](https://github.com/purescript/purescript/tree/master/psc-ide). Make sure
your project is built first.

Completions will be sourced from modules imported in the current file.

## Build and error reporting

After you've added `settings.json` for your build system,
Shift+Ctrl+B builds it.
if you are not sure which `settings.json` it is, pick the Spago -one.

## Case split

The case split expands the case under the cursor.
If you add this under a shortcut, you can quickly autocomplete large case clauses.

## Add clause

The add clause reads the type declaration under the cursor
and inserts an empty template under it.
You can then fill this template.
This is best in combination with the case split.

## Tooltips

Hovering over an identifier will show a tooltip with its type.

This feature is really stupid, only caring that you hover over a word regardless of context, you will get some false positives
(eg doesn't see local definitions, just the globals that should be visible in a given module).

Hovering over a qualifier of a qualified identifier will show the associated module name.

## Go to symbol

The go to symbol can be found from the go to menu.

## Go to definitions

Hyperclick goto-definition functionality is supported. This is available with `purs` version
0.9.2 and above, and like tooltips/autocomplete works on identifiers bound at the top level.

In case source positions are not up to date, they may not be updated on rebuild, try rebuilding or restarting psc-ide server.

## Pursuit lookup

Commands "Search Pursuit" and "Search Pursuit Modules" are available to search for identifiers or modules/packages on Pursuit.

## PSCI

No particular support. Suggest you open a PSCI in the integrated terminal.

## Development

To develop (rather than use) this extension, see [the instructions](https://github.com/nwolverson/purescript-language-server/blob/master/README.md#development) in `purescript-language-server`.

