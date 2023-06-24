{
  config,
  lib,
  pkgs,
  inputs,
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
        autoNumlock = true;
        settings = {
          AutoLogin = {
            Session = "hyprland";
            User = "${username}";
          };
        };
        wayland.enable = true;
        theme = "sugar-catppuccin";
      };
    };
    environment.systemPackages = [
      # Only for x86-64
      inputs.sddm-sugar-catppuccin.packages.${pkgs.system}.default
    ];
  };
}
