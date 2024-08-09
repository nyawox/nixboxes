{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.modules.desktop.gaming;
in {
  options = {
    modules.desktop.gaming = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };
  config = mkIf cfg.enable {
    programs = {
      gamescope = {
        enable = true;
        capSysNice = true;
        args = [
          "--force-grab-cursor"
        ];
      };
      steam = {
        enable = true;
        extest.enable = true;
        extraCompatPackages = with pkgs; [
          proton-ge-bin
          steamtinkerlaunch
        ];
        extraPackages = with pkgs; [gamescope mangohud lutris prismlauncher];
        gamescopeSession = {
          enable = true;
        };
        protontricks.enable = true;
      };
    };
  };
}
