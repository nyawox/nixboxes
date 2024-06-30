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
        url = "https://images.hdqwalls.com/download/train-of-outrun-world-t9-3840x2400.jpg";
        sha256 = "0ax48hjpf48zg9j7b51c7j1cdy4vr3a6r8k2jgzckdn30f3hq94b";
      };
    };
    xdg.configFile = {
      "cava/config".source = inputs.catppuccin-cava.outPath + "/mocha.cava";
    };
  };
}
