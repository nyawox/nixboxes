{
  config,
  lib,
  pkgs,
  inputs,
  username,
  ...
}:
with lib; let
  cfg = config.modules.desktop.greetd;
in {
  options = {
    modules.desktop.greetd = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };
  config = mkIf cfg.enable {
    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd ${inputs.hyprland.packages.${pkgs.system}.hyprland}/bin/Hyprland";
          user = "${username}";
        };
        intial_session = {
          command = "${inputs.hyprland.packages.${pkgs.system}.hyprland}/bin/Hyprland";
          user = "${username}";
        };
      };
    };
  };
}
