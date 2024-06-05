{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.sysconf.resolved;
in {
  options = {
    modules.sysconf.resolved = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Enable systemd-resolved
        '';
      };
    };
  };
  config = mkIf cfg.enable {
    networking.nameservers = [
      "9.9.9.9"
      "149.112.112.112"
    ];

    services.resolved = {
      enable = true;
      dnssec = "true";
      domains = ["~."];
      fallbackDns = [
        "9.9.9.9"
        "149.112.112.112"
      ];
      extraConfig = ''
        DNSOverTLS=yes
      '';
    };
  };
}
