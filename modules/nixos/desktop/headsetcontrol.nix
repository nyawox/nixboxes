{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.modules.desktop.headsetcontrol;
in {
  options = {
    modules.desktop.headsetcontrol = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages = [pkgs.headsetcontrol];
    services.udev.packages = [pkgs.headsetcontrol];
  };
}
