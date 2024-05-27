{ config, lib, ... }:
with lib;
let
  cfg = config.modules.sysconf.silentboot;
in
{
  options = {
    modules.sysconf.silentboot = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = ''
          https://wiki.archlinux.org/title/Silent_boot
        '';
      };
    };
  };
  config = mkIf cfg.enable {
    boot = mkIf config.boot.plymouth.enable {
      consoleLogLevel = 0;
      kernelParams = [
        "quiet"
        "udev.log_level=3"
      ];
    };
  };
}
