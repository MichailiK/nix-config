{
  sequoia-chameleon-gnupg,
  # unused options that are used in the GnuPG package to ensure compatibility
  # in case anyone uses overlays to replace the gnupg package with chameleon
  stdenv,
  enableMinimal ? false,
  withPcsc ? !enableMinimal,
  guiSupport ? stdenv.hostPlatform.isDarwin,
  withTpm2Tss ? !stdenv.hostPlatform.isDarwin && !enableMinimal,
  ...
}:
stdenv.mkDerivation {
  pname = "gnupg";
  version = "sequoia-chameleon-${sequoia-chameleon-gnupg.version}";
  src = sequoia-chameleon-gnupg;

  installPhase = ''
    runHook preInstall

    mkdir -p "$out"/bin
    ln -s "$src"/bin/gpg-sq "$out"/bin/gpg
    ln -s "$src"/bin/gpgv-sq "$out"/bin/gpgv

    runHook postInstall
  '';

  meta.mainProgram = "gpg";
}
