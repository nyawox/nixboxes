{ config, lib, ... }:
with lib;
let
  cfg = config.modules.sysconf.wifi;
in
{
  options = {
    modules.sysconf.wifi = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
      homewifiSSID = mkOption {
        type = types.str;
        default = "AP-5G";
        description = ''
          Default wifi SSID used on iwd.
          The ssid appears verbatim in the name if it contains only alphanumeric characters, spaces, underscores or minus signs.
          Otherwise it is encoded as an equal sign followed by the lower-case hex encoding of the name.
        '';
      };
      home2GwifiSSID = mkOption {
        type = types.str;
        default = "=4150332d322e3447";
        description = ''
          Default wifi SSID used on iwd
          The ssid appears verbatim in the name if it contains only alphanumeric characters, spaces, underscores or minus signs.
          Otherwise it is encoded as an equal sign followed by the lower-case hex encoding of the name.
        '';
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
    environment.persistence."/persist".directories = mkIf config.modules.sysconf.impermanence.enable [
      "/var/lib/iwd"
    ];
    systemd.tmpfiles.rules = [
      "C /var/lib/iwd/${cfg.homewifiSSID}.psk 0600 root root - ${config.sops.secrets."home.psk".path}"
      "C /var/lib/iwd/${cfg.home2GwifiSSID}.psk 0600 root root - ${config.sops.secrets."home.psk".path}"
    ];
  };
}
