let upstream =
      https://github.com/purescript/package-sets/releases/download/psc-0.15.2-20220706/packages.dhall
        sha256:7a24ebdbacb2bfa27b2fc6ce3da96f048093d64e54369965a2a7b5d9892b6031

in  upstream
  with pursuit-lookup =
    { dependencies =  [ "aff"
  , "affjax"
  , "affjax-node"
  , "argonaut"
  , "arrays"
  , "either"
  , "maybe"
  , "media-types"
  , "prelude"
  ]
    , repo = "https://github.com/nwolverson/purescript-pursuit-lookup.git"
    , version = "82a25f7bc792f3794a9accb3ec771e7e832242c4"
    }
  
  with psc-ide.version = "ccd4260b9b5ef8903220507719374a70ef2dd8f1"
  with language-server =
    { dependencies =
       [ "aff"
  , "aff-promise"
  , "argonaut"
  , "argonaut-codecs"
  , "argonaut-core"
  , "arrays"
  , "avar"
  , "bifunctors"
  , "console"
  , "contravariant"
  , "control"
  , "datetime"
  , "effect"
  , "either"
  , "enums"
  , "exceptions"
  , "foldable-traversable"
  , "foreign"
  , "foreign-generic"
  , "foreign-object"
  , "integers"
  , "js-date"
  , "js-timers"
  , "language-cst-parser"
  , "lists"
  , "literals"
  , "maybe"
  , "newtype"
  , "node-buffer"
  , "node-child-process"
  , "node-fs"
  , "node-fs-aff"
  , "node-path"
  , "node-process"
  , "node-streams"
  , "nonempty"
  , "nullable"
  , "ordered-collections"
  , "parallel"
  , "prelude"
  , "profunctor"
  , "profunctor-lenses"
  , "psc-ide"
  , "psci-support"
  , "refs"
  , "strings"
  , "stringutils"
  , "test-unit"
  , "transformers"
  , "tuples"
  , "unsafe-coerce"
  , "untagged-union"
  , "uuid"
  ]
    , repo = "https://github.com/nwolverson/purescript-language-server.git"
    , version = "v0.17.0"
    }

  -- with affjax.version = "69427eda42c313e09d2064b620323e1c3e7dd6ac"
  -- with affjax.repo = "https://github.com/nwolverson/purescript-affjax.git"
  with foreign-generic =
    { dependencies =
      [ "effect"
      , "exceptions"
      , "foreign"
      , "foreign-object"
      , "identity"
      , "ordered-collections"
      , "record"
      ]
    , repo =
        "https://github.com/working-group-purescript-es/purescript-foreign-generic.git"
    , version = "53410dd57e9b350d6c233f48f7aa46317c4faa21"
    }
  with uuid =
    { dependencies = [ "effect", "maybe", "foreign-generic", "console", "spec" ]
    , repo = "https://github.com/megamaddu/purescript-uuid.git"
    , version = "7bb5a90c9b11f6a33ac7610608a650e4d58aeac9"
    }

  with untagged-union =
    { dependencies =
      [ "assert"
  , "console"
  , "effect"
  , "either"
  , "foreign"
  , "foreign-object"
  , "literals"
  , "maybe"
  , "newtype"
  , "prelude"
  , "tuples"
  , "unsafe-coerce"
      ]
    , repo =
        "https://github.com/rowtype-yoga/purescript-untagged-union.git"
    , version = "ed8262a966e15e751322c327e2759a9b9c0ef3f3"
    }


