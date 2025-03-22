{
  environment.extraInit = ''
    run () {
      PACKAGE=$1; shift
      nix run nixpkgs#$PACKAGE -- $@
    }

    runi () {
      PACKAGE=$1; shift
      nix run --impure nixpkgs#$PACKAGE -- $@
    }
  '';
}