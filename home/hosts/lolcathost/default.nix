{
  lib,
  pkgs,
  ...
}:
let
  folder = ./.;
  toImport = name: _value: folder + ("/" + name);
  filterCaches = key: value: value == "regular" && lib.hasSuffix ".nix" key && key != "default.nix";
  imports = lib.mapAttrsToList toImport (lib.filterAttrs filterCaches (builtins.readDir folder));
in
{
  inherit imports;
  modules = {
    desktop = {
      zathura.enable = true;
    };
  };
  home.file.".local/share/PrismLauncher/themes/Catppuccin-Mocha".source =
    let
      zip = pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/catppuccin/prismlauncher/423e359d6c17b0339e8c851bb2953bcf5c7e1e49/themes/Mocha/Catppuccin-Mocha.zip";
        sha256 = "03y76qlsnrjkvd79his5jlaq9rqp2j3x1g101js0sm4iiv4q0l5a";
      };
    in
    pkgs.stdenv.mkDerivation {
      name = "catppuccin-prismlauncher";
      nativeBuildInputs = [ pkgs.unzip ];
      src = zip;
      sourceRoot = ".";
      unpackCmd = "unzip $src";
      dontConfigure = true;
      dontBuild = true;
      installPhase = ''
        mkdir -p $out
        cp -R Catppuccin-Mocha/* $out/
      '';
    };
}
