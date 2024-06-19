{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:
with lib; let
  cfg = config.modules.common.files;
in {
  options = {
    modules.common.files = {
      enable = mkOption {
        type = types.bool;
        default = true;
      };
    };
  };
  config = mkIf cfg.enable {
    home.file = {
      ".wallpaper.jpg".source = pkgs.fetchurl {
        url = "https://w.wallhaven.cc/full/ex/wallhaven-exo2gr.jpg";
        sha256 = "0ki8im2907yzzjbk60cxq8lg2vrjzbs3qlg7jf6vsry9x20n4rz1";
      };
    };
    xdg.configFile = {
      "cava/config".source = inputs.catppuccin-cava.outPath + "/mocha.cava";
    };
  };
}
