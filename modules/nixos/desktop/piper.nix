{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.modules.desktop.piper;
in
{
  options = {
    modules.desktop.piper = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };
  config = mkIf cfg.enable {
    services.ratbagd.enable = true;
    environment.systemPackages = [ pkgs.piper ];
  };
}
