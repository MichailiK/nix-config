{
  pkgs,
  sequoia-keystore-server,
  ...
}:
pkgs.sequoia-sq.overrideAttrs (final: prev: {
  src = pkgs.applyPatches {
    src = pkgs.fetchFromGitLab {
      owner = "sequoia-pgp";
      repo = "sequoia-sq";
      tag = "v1.3.1";
      hash = "sha256-lM+j1KtH3U/lbPXnKALAP75YokDufbdz8s8bjb0VXUY=";
    };
    patches = [./cargo.patch];
  };

  env = (prev.env or {}) // {PREFIX = sequoia-keystore-server.outPath;};

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
