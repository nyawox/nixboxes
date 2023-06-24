{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.modules.desktop.swayidle;
in
{
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
      timeouts = [
        {
          timeout = 601;
          command = "${pkgs.niri-unstable}/bin/niri msg action power-off-monitors";
        }
        {
          timeout = 600;
          command = "${getExe pkgs.swaylock-effects} --screenshots --clock --indicator --indicator-radius 100 --indicator-thickness 7 --effect-blur 7x5 --effect-vignette 0.5:0.5 --ring-color f5c2e7 --text-color cdd6f4 --key-hl-color fab387 --line-color 00000000 --inside-color 1e1e2e88 --separator-color 00000000 --grace 2 --fade-in 0.2";
        }
      ];
    };
    systemd.user.services.swayidle.Unit.After = "niri.service";
  };
}
