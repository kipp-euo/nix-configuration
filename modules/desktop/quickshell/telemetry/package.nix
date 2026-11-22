{ stdenv }:

stdenv.mkDerivation {
  pname = "qs-telemetry";
  version = "0.1.0";

  src = ./src;

  dontUnpack = true;

  buildPhase = ''
    runHook preBuild
    $CXX -std=c++20 -O2 -pipe -Wall -Wextra -Wpedantic \
      ${./src/main.cpp} -ldl -o qs-telemetry
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install -Dm755 qs-telemetry "$out/bin/qs-telemetry"
    runHook postInstall
  '';

  meta = {
    description = "Low-overhead telemetry collector for the Quickshell top bar";
  };
}
