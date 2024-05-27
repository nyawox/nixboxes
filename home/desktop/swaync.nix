{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.modules.desktop.swaync;
in
{
  options = {
    modules.desktop.swaync = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      swaynotificationcenter
      (nerdfonts.override { fonts = [ "Ubuntu" ]; })
    ];
    xdg.configFile."swaync/style.css".source = pkgs.fetchurl {
      url = "https://github.com/catppuccin/swaync/releases/download/v0.1.2.1/mocha.css";
      sha256 = "19z41gvds15av1wpidzli1yqbm70fmdv04blr23ysbl944jvfvnv";
    };
  };
}
