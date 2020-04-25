{-
Welcome to a Spago project!
You can edit this file as you like.
-}
{ name = "vscode-ide-purescript"
, dependencies = [ "console", "effect", "psci-support", "language-server", "pursuit-lookup" ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
}
