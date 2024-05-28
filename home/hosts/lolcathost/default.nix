{
  lib,
  pkgs,
  inputs,
  username,
  ...
}:
let
  folder = ./.;
  toImport = name: _value: folder + ("/" + name);
  filterCaches = key: value: value == "regular" && lib.hasSuffix ".nix" key && key != "default.nix";
  imports = lib.mapAttrsToList toImport (lib.filterAttrs filterCaches (builtins.readDir folder));

  apps = {
    env = "/run/current-system/sw/bin:/run/wrappers/bin:/home/${username}/.nix-profile/bin:/etc/profiles/per-user/${username}/bin:/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin";
    apps = [
      {
        name = "Desktop";
        image-path = "desktop.png";
      }
    ];
  };
in
{
  inherit imports;
  modules = {
    desktop = {
      vivaldi.enable = true;
      zathura.enable = true;
    };
    shell.yazi.enable = true;
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
  xdg.configFile = {
    "sunshine/sunshine.conf".source = ./sunshine.conf;
    "sunshine/apps.json".text = builtins.toJSON apps;
    "Element/config.json".source = inputs.catppuccin-element.outPath + "/config.json";
  };
}
