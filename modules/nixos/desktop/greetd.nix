{
  config,
  lib,
  pkgs,
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
          command = "${pkgs.greetd.tuigreet}/bin/tuigreet --astericks --time --cmd Hyprland";
          user = "${username}";
        };
        intial_session = {
          command = "Hyprland";
          user = "${username}";
        };
      };
    };
  };
}
