let
  pinnedNixHash = "b7fc729117a70d0df9e9adfc624662148e32ca0a";
  pinnedNix =
    builtins.fetchGit {
      name = "nixpkgs-pinned";
      url = "https://github.com/NixOS/nixpkgs.git";
      rev = "${pinnedNixHash}";
    };

  nixpkgs =
    import pinnedNix {
  };

  easy-ps = import
    (nixpkgs.pkgs.fetchFromGitHub {
      ## Temporarily on Fabrizio's fork to get spago-next
      owner = "f-f";
      repo = "easy-purescript-nix";
      rev = "2e62b746859e396e541bdd63dbd10b2f231027d4";
      sha256 = "sha256-qQpWKE40wKkxb4y2+z0n4lF/OFrCsEU3Gwiugl3H+xc=";
    }) { pkgs = nixpkgs; };


in
nixpkgs.mkShell {
  buildInputs = [
    easy-ps.purs-0_15_9-2
    easy-ps.spago
    easy-ps.psa

  ];
}
