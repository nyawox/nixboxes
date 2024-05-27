{
  stdenv,
  lib,
  sources,
}:
stdenv.mkDerivation {
  inherit (sources.catppuccin-fcitx5) pname version src;

  dontBuild = true;
  dontConfigure = true;

  installPhase = ''
    install -d $out/share/fcitx5/themes/
            cp -r ./src/* $out/share/fcitx5/themes/
  '';

  meta = with lib; {
    homepage = "https://github.com/catppuccin/fcitx5";
    description = "Soothing pastel theme for Fcitx5 ";
    license = licenses.mit;
  };
}
