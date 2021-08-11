# Changelog

## 0.25.1

* Updates from `purescript-language-server` version `0.15.4`

- Auto build of opened files is now behind a setting `purescript.buildOpenedFiles` and defaulted to `false`, this should be 
  considered experimental for the time being. There are 2 issues which become more likely to be triggered by this feature,
  firstly rebuilding (even unchanged) files can cause downstream modules to require rebuilding in an incremental build ([issue](https://github.com/purescript/purescript/issues/4066)) and secondly there are reports that fast-rebuilding a file during a full/incremental build can cause corrupt output.

- Formatting provider selection: Now `purescript.formatter` can be set to `purty` (the previous formatter and still the default),
  `purs-tidy` or `pose`. Requires these tools to be already installed

- Internal changes that could avoid a case of the language server crashing abruptly

## 0.25.0

* Updates from `purescript-language-server` version `0.15.2`

- The code action with kind `source.organizeImports` is now the action which applies all compiler suggestions
  for unused imports, `source.sortImports` is added (previously "Organize imports") to align with the changes for JS/TS
  languages in vscode 1.57. This can be used with `editor.codeActionsOnSave` or key-bound with `editor.action.sourceAction`.
- Show a warning dialog (with build option) on start if we get an externs out of date error
- Remove deprecated editor mode/polling purs ide config (Removed in 0.13.8)

* Updates from `purescript-language-server` version `0.15.1`

- Add `flake.nix` and `shell.nix` to the list of files that indicate a PS project may be present #136, #137 (@ursi)
- Change the way the `purty` formatter is spawned to make it faster
- Don't fix implicit prelude in all (import) suggestions. #108
- Add auto build of opened files #125 (@wclr)
- Build with PureScript 0.14.x, CI udpates

# 0.24.0

* Updates from `purescript-language-server` version `0.15.0`

- Add support for importing conflicting identifiers #118 (@i-am-the-slime)
- Parse build output from both stdout/stderr (required for PureScript 0.14.0). #111
- Prioritize "Organise Imports" action lower than others #113

## 0.19.1-0.23.3

* See `purescript-language-server` changelog to `0.14.4"`

## 0.19.0

* Updates from `purescript-language-server` version `0.11.0`:
  - Add find references command (requires purs 0.12). Currently works at the value level

## 0.18.2

* Updates from `purescript-language-server` version `0.10.2`:
  - Add warning/build option on missing output directory - https://github.com/nwolverson/purescript-language-server/commit/83e7f2b884915100318bb6a06eb5b59fd7e39354

## 0.18.1

* Updates from `purescript-language-server` version `0.10.1`:
  - Respect `pscIdePort` config - when absent port will be auto-chosen, when present server will be found or started on that port
  - Respect `autoStartPscIde` config
  - Make `executeCommandProvider` optional
  - `fixTypo` position fix

## 0.18.0

* Updates from `purescript-language-server` version `0.10.0`:
  - Replace typed hole command & code action (requires LSP client support) https://github.com/nwolverson/purescript-language-server/issues/14
  - Move dependencies from purescript-ide-purescript-core
  - Configurable output directory #30
  - Fix all suggestions commands https://github.com/nwolverson/purescript-language-server/issues/12

## 0.17.0

* Updates from `purescript-language-server` version `0.9.0`:
  - Add documentation to hover tooltips https://github.com/nwolverson/purescript-language-server/pull/25 [@Krzysztof-Cieslak](https://github.com/Krzysztof-Cieslak)
  - Make compiler fixes (particularly import fixes) not leave extra blank lines https://github.com/nwolverson/purescript-language-server/issues/13
  - Fix `preludeModule` adding a prelude import if it is already imported explicitly https://github.com/nwolverson/purescript-language-server/issues/26
  - Ensure IDE server dependencies are reloaded on full build (particularly in case of editor mode) https://github.com/nwolverson/purescript-language-server/issues/19
  - Fix completion edits in some circumstances https://github.com/nwolverson/vscode-ide-purescript/issues/96

## 0.16.0

* Updates from `purescript-language-server` version `0.8.0`:
  - Add suggestion ranking heuristics, currently these are for qualified import suggestiosn https://github.com/nwolverson/purescript-language-server/pull/15 @natefaubion
  - Add configurable Prelude open import via `preludeModule` https://github.com/nwolverson/purescript-language-server/pull/16 @natefaubion
  - Use Markdown for suggestion details https://github.com/nwolverson/purescript-language-server/pull/23 @Krzysztof-Cieslak

## 0.15.0

* Updates from `purescript-language-server` version `0.7.1`:
  - Automatically add qualified imports on completion with an unknown qualifier https://github.com/nwolverson/purescript-language-server/pull/7 @natefaubion
  - Fix extraneous newlines in case split/add clause https://github.com/nwolverson/purescript-language-server/pull/9

## 0.14.0

* Updates from `purescript-language-server` version `0.6.0`:
  - Support psc-package source globs. Toggled via `addPscPackageSources` config (default `false`) and using `psc-package sources` command.
  - Show expanded type in tooltips (when different from non-expanded one)
  - Show module tooltip for qualified imports (hover over the qualifier of a qualified identifier)

## 0.13.0

* Pursuit search restored and Pursuit module search added (scope to actually do something on selection at some point).

## 0.12.0

* Multi-root workspace support

  This is basic support via launching multiple language server instances. Should launch an instance whenever a file is opened under a particular workspace root folder, and stop an instance only when removing the folder from the workspace.

  Tested for basic interaction but may run into issues for less file-based commands on additional workspaces?

* Support `purs ide server` `--editor-mode` flag

* Extracted [purescript-language-server](https://github.com/nwolverson/purescript-language-server) to a separate repository

* Various imports commands fixes

## 0.11.3

* Suppress logged error on unnecessary import

## 0.11.2

* Restore notification on building