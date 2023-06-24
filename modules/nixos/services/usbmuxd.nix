{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.modules.services.usbmuxd;
in
{
  options = {
    modules.services.usbmuxd = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };
  config = mkIf cfg.enable {
    services.usbmuxd = {
      enable = true;
      package = pkgs.usbmuxd2;
    };
  };
}
