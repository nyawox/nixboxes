{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.sysconf.wifi;
in {
  options = {
    modules.sysconf.wifi = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };
  config = mkIf cfg.enable {
    networking.wireless = {
      iwd = {
        enable = true;
        settings = {
          General.EnableNetworkConfiguration = true;
          Network = {
            EnableIPv6 = true;
            RoutePriorityOffset = 300;
          };
          Settings = {
            AutoConnect = true;
          };
        };
      };
    };
    sops.secrets."home.psk" = {
      sopsFile = ../../../secrets/home.psk;
      format = "binary";
    };
    environment.persistence."/persist".directories = mkIf config.modules.sysconf.impermanence.enable ["/var/lib/iwd"];
    systemd.tmpfiles.rules = [
      "C /var/lib/iwd/${config.secrets.homewifiSSID}.psk 0600 root root - ${config.sops.secrets."home.psk".path}"
      "C /var/lib/iwd/${config.secrets.home2GwifiSSID}.psk 0600 root root - ${config.sops.secrets."home.psk".path}"
    ];
  };
}
