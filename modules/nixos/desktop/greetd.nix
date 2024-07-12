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
          command = "${getExe pkgs.greetd.tuigreet} --time --cmd ${pkgs.niri-unstable}/bin/niri-session";
          user = "${username}";
        };
        intial_session = {
          command = "${pkgs.niri-unstable}/bin/niri-session";
          user = "${username}";
        };
      };
    };
  };
}
