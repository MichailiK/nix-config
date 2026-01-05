{
  applyPatches,
  fetchFromGitLab,
  lib,
  nettle,
  rustPlatform,
  pkg-config,
  capnproto,
  pcsclite,
  ...
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "sequoia-keystore-server";
  version = "0.3.0-dev";

  src = applyPatches {
    src = fetchFromGitLab {
      owner = "sequoia-pgp";
      repo = "sequoia-keystore";
      rev = "0353be8de07d7807765f95d80012dfebff731416";
      hash = "sha256-OkyTJN/beJHB5VrBVVBd7ldglom+B+/P3a1C61O+fuw=";
    };
    patches = [./cargo.patch];
  };

  cargoHash = "sha256-HQTYwFanBAM7LIyPZx1po/lBvCNYtJSkDZzhjg1u7kc=";

  buildAndTestSubdir = "server";

  nativeBuildInputs = [
    pkg-config
    rustPlatform.bindgenHook
    capnproto
  ];

  buildInputs = [
    nettle
    pcsclite.dev
  ];

  fixupPhase = ''
    runHook preFixup

    mkdir -p $out/lib/sequoia
    mv $out/bin/* $out/lib/sequoia
    rm -r $out/bin

    runHook postFixup
  '';

  doCheck = true;
})
