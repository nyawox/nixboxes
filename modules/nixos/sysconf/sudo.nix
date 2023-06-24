{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.modules.sysconf.sudo;
in
{
  options = {
    modules.sysconf.sudo = {
      enable = mkOption {
        type = types.bool;
        default = true;
      };
    };
  };
  config = mkIf cfg.enable {
    security.sudo-rs = {
      enable = true;
      execWheelOnly = true;
    };
    security.sudo.enable = false;
  };
}
