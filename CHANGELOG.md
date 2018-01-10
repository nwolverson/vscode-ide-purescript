# Changelog

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