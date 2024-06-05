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
        url = "https://i.pinimg.com/originals/24/ca/db/24cadbfc4de7599a86ef5e8bc238853e.jpg";
        sha256 = "1fraqngiw0l164i1ar7i3bzq0bz7zdcvydqgxrr0rqqq3y4rq6sv";
      };
    };
    xdg.configFile = {
      "cava/config".source = inputs.catppuccin-cava.outPath + "/mocha.cava";
    };
  };
}
