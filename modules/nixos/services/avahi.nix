{ config, lib, ... }:
with lib;
let
  cfg = config.modules.services.avahi;
in
{
  options = {
    modules.services.avahi = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };
  config = mkIf cfg.enable {
    # ssh with hostanme
    services.avahi = {
      enable = true;
      nssmdns6 = true;
      # publish/announce machine
      publish = {
        enable = true;
        addresses = true;
        domain = true;
        userServices = true;
        hinfo = true;
        workstation = true;
      };
    };
  };
}
