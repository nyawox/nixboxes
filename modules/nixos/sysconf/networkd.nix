{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.sysconf.networkd;
in {
  options = {
    modules.sysconf.networkd = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Enable systemd-networkd
        '';
      };
    };
  };
  config = mkIf cfg.enable {
    systemd.network.enable = true;
    networking.useNetworkd = true;
    systemd.network.wait-online = {
      anyInterface = true;
      timeout = 0;
    };
  };
}
