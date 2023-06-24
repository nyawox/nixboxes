{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.modules.services.tang;
in
{
  options = {
    modules.services.tang = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };
  config = mkIf cfg.enable {
    services.tang = {
      enable = true;
      ipAddressAllow = [
        # "192.168.0.1/24" TBD
      ];
    };
  };
}
