let upstream =
      https://github.com/purescript/package-sets/releases/download/psc-0.14.5-20220203/packages.dhall sha256:f8905bf5d7ce9d886cf4ef1c5893ab55de0b30c82c2b4137f272d075000fbc50
  -- https://github.com/purescript/package-sets/releases/download/psc-0.14.1-20210516/packages.dhall sha256:f5e978371d4cdc4b916add9011021509c8d869f4c3f6d0d2694c0e03a85046c8


in  upstream
  with pursuit-lookup =
    { dependencies = [ "argonaut", "affjax", "argonaut-codecs", "prelude" ]
    , repo = "https://github.com/nwolverson/purescript-pursuit-lookup.git"
    , version = "44283e54c8e7d033a714ee4d20d1dbfd0e2fd8d4"
    }
  with psc-ide.version = "b9b1d0320204927cafefcf24b105ec03d0ae256b"
  with language-server =
    { dependencies =
       [ "aff-promise"
          , "console"
          , "effect"
          , "errors"
          , "foreign-generic"
          , "node-child-process"
          , "node-fs-aff"
          , "node-process"
          , "psc-ide"
          , "psci-support"
          , "stringutils"
          , "test-unit"
          , "uuid"
          , "language-cst-parser"
          ]
    , repo = "https://github.com/nwolverson/purescript-language-server.git"
    , version = "v0.16.5"
    }
  with language-cst-parser =
    { dependencies =
      [ "arrays"
      , "console"
      , "const"
      , "debug"
      , "effect"
      , "either"
      , "filterable"
      , "foldable-traversable"
      , "free"
      , "functors"
      , "maybe"
      , "numbers"
      , "psci-support"
      , "strings"
      , "transformers"
      , "tuples"
      , "typelevel-prelude"
      ]
    , repo = "https://github.com/natefaubion/purescript-language-cst-parser.git"
    , version = "v0.9.3"
    }
  with affjax.version = "69427eda42c313e09d2064b620323e1c3e7dd6ac"
  with affjax.repo = "https://github.com/nwolverson/purescript-affjax.git"
