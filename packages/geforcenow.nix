{
  stdenv,
  autoPatchelfHook,
  alsa-lib,
  lib,
  openssl,
  zlib,
}:
# Add any other library packages your binary needs to the curly braces above
stdenv.mkDerivation rec {
  pname = "geforcenow"; # Replace with your program's name

  src = ./GeForceNOWSetup.bin; # Replace with the path if the file is local

  nativeBuildInputs = [autoPatchelfHook];
  buildInputs = [alsa-lib openssl zlib]; # Add all dependencies here

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall
    install -m755 -D ${src} $out/bin/my-program # Stays executable
    runHook postInstall
  '';

  meta = with lib; {
    description = "geforcenow";
    platforms = platforms.linux;
  };
}
