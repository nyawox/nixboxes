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
        url = "https://raw.githubusercontent.com/nyawox/store/main/pink_tile.png";
        sha256 = "0pp98mq6gblja9x44whgndq072rckw11iz1iml3j564b6jap6sp6";
      };
    };
    xdg.configFile = {
      "cava/config".source = inputs.catppuccin-cava.outPath + "/mocha.cava";
    };
  };
}
