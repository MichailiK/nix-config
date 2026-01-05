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
  version = "0.2.0";

  src = applyPatches {
    src = fetchFromGitLab {
      owner = "sequoia-pgp";
      repo = "sequoia-keystore";
      tag = "server/v${finalAttrs.version}";
      hash = "sha256-UqlrMh1dDnykr69kR+fikx+mk9WsF9Y8jsfazKCvXV4=";
    };
    patches = [./cargo.patch];
  };

  cargoHash = "sha256-uTpJzYncRQBs/mXiJylqmNw0/j4ia1MM4hhZ20g9Muw=";

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
