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
      ".wallpaper.png".source = pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/Keyitdev/sddm-astronaut-theme/master/background.png";
        sha256 = "1bvfc33gw6hj7s6dk6hzsn4aq2ymmjvyx4qgwnnl4k9gg29g12im";
      };
    };
    xdg.configFile = {
      "cava/config".source = inputs.catppuccin-cava.outPath + "/mocha.cava";
    };
  };
}
