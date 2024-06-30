{
  pkgs,
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.modules.desktop.swayidle;
in {
  options = {
    modules.desktop.swayidle = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };
  config = mkIf cfg.enable {
    services.swayidle = {
      enable = true;
      systemdTarget = "niri.service";
      events = [
        {
          event = "before-sleep";
          command = "${pkgs.swaylock-effects}/bin/swaylock --screenshots --clock --indicator --indicator-radius 100 --indicator-thickness 7 --effect-blur 7x5 --effect-vignette 0.5:0.5 --ring-color f5c2e7 --text-color cdd6f4 --key-hl-color fab387 --line-color 00000000 --inside-color 1e1e2e88 --separator-color 00000000 --grace 2 --fade-in 0.2";
        }
        {
          event = "lock";
          command = "sleep 5s; ${pkgs.niri-unstable}/bin/niri msg action power-off-monitors";
        }
      ];
      timeouts = [
        {
          timeout = 600; # 10 Minutes
          command = "${pkgs.swaylock-effects}/bin/swaylock --screenshots --clock --indicator --indicator-radius 100 --indicator-thickness 7 --effect-blur 7x5 --effect-vignette 0.5:0.5 --ring-color f5c2e7 --text-color cdd6f4 --key-hl-color fab387 --line-color 00000000 --inside-color 1e1e2e88 --separator-color 00000000 --grace 2 --fade-in 0.2";
        }
        {
          timeout = 300; # 5 Minutes
          command = "${pkgs.niri-unstable}/bin/niri msg action power-off-monitors";
        }
      ];
    };
  };
}
