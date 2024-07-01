{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.modules.desktop.xwayland;
in {
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
      xwayland-satellite
    ];
    programs.niri.settings = {
      spawn-at-startup = [
        {command = ["${pkgs.xwayland-satellite}/bin/xwayland-satellite" ":25"];}
      ];
      environment = {
        DISPLAY = ":25";
      };
    };
  };
}
