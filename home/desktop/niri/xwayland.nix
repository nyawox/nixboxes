{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.modules.desktop.xwayland;
in
{
  options = {
    modules.desktop.xwayland = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      xwayland
      xwayland-satellite-unstable
    ];
    programs.niri.settings = {
      spawn-at-startup = [
        {
          command = [
            "${getExe pkgs.xwayland-satellite-unstable}"
            ":25"
          ];
        }
      ];
      environment = {
        DISPLAY = ":25";
      };
    };
  };
}
