{
  stdenv,
  lib,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "catppuccin-fcitx5";
  version = "ce244cfdf43a648d984719fdfd1d60aab09f5c97";
  src = fetchFromGitHub {
    owner = "catppuccin";
    repo = "fcitx5";
    rev = "ce244cfdf43a648d984719fdfd1d60aab09f5c97";
    fetchSubmodules = false;
    sha256 = "sha256-uFaCbyrEjv4oiKUzLVFzw+UY54/h7wh2cntqeyYwGps=";
  };

  dontBuild = true;
  dontConfigure = true;

  installPhase =
    # bash
    ''
      install -d $out/share/fcitx5/themes/
      cp -r ./src/* $out/share/fcitx5/themes/
    '';

  meta = with lib; {
    homepage = "https://github.com/catppuccin/fcitx5";
    description = "Soothing pastel theme for Fcitx5 ";
    license = licenses.mit;
  };
}
