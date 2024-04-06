{
  config,
  lib,
  pkgs,
  username,
  ...
}:
with lib; let
  cfg = config.modules.desktop.sddm;
in {
  options = {
    modules.desktop.sddm = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };
  config = mkIf cfg.enable {
    services.xserver.displayManager = {
      gdm.enable = false;
      sddm = {
        enable = true;
        enableHidpi = false;
        settings = {
          AutoLogin = {
            Session = "hyprland";
            User = "${username}";
          };
        };
        wayland.enable = true;
        theme = "chili";
      };
    };
    environment.systemPackages = [
      (pkgs.sddm-chili-theme.override {
        themeConfig = {
          background = config.stylix.image;
          changeFontPointSize = 9;
          ScreenWidth = 1920;
          ScreenHeight = 1080;
          recursiveBlurLoops = 4;
          recursiveBlurRadius = 15;
          blur = true;
        };
      })
    ];
  };
}
