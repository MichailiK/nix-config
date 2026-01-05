{
  pkgs,
  sequoia-keystore-server,
  ...
}:
pkgs.sequoia-sq.overrideAttrs (final: prev: {
  version = "1.3.1-dev";
  src = pkgs.applyPatches {
    src = pkgs.fetchFromGitLab {
      owner = "sequoia-pgp";
      repo = "sequoia-sq";
      rev = "52b74be7a5406e264631c73d3e03086fcc228ecc";
      hash = "sha256-3vH1gzgN2ZSzsfxk466+arE1i5MCcgF07KIaADkaICA=";
    };
    patches = [./cargo.patch];
  };

  env = (prev.env or {}) // {PREFIX = sequoia-keystore-server.outPath;};

  buildAndTestSubdir = "tool";

  buildInputs =
    (prev.buildInputs or [])
    ++ [
      pkgs.pcsclite.dev
    ];

  cargoDeps = pkgs.rustPlatform.importCargoLock {
    lockFile = final.src + "/Cargo.lock";
    allowBuiltinFetchGit = true;
  };

  # integration::sq_key_delete::ambiguous stdout integration test failure
  doCheck = false;
})
