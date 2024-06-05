{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.services.headscale;
  domain = "headscale.nixlap.top";
  derpPort = 3478;
in {
  options = {
    modules.services.headscale = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };
  config = mkIf cfg.enable {
    services = {
      headscale = {
        enable = true;
        address = "0.0.0.0";
        port = 8085;
        settings = {
          dns_config = {
            magic_dns = true;
            base_domain = "nixlap.top";
            nameservers = [
              "9.9.9.9"
              "149.112.112.112"
            ];
            # Magic DNS not working without this
            # https://github.com/juanfont/headscale/issues/660
            override_local_dns = true;
          };
          logtail.enabled = false;
          server_url = "https://${domain}";
          derp.server = {
            enable = true;
            region_id = 999;
            stun_listen_addr = "0.0.0.0:${toString derpPort}";
          };
        };
      };

      caddy.virtualHosts.${domain} = {
        useACMEHost = "nixlap.top";
        extraConfig = ''
          reverse_proxy http://[::1]:8085
        '';
      };
    };

    environment.systemPackages = [config.services.headscale.package];
    networking.firewall.allowedTCPPorts = [
      80
      443
    ];
    networking.firewall.allowedUDPPorts = [derpPort];

    environment.persistence."/persist".directories = mkIf config.modules.sysconf.impermanence.enable [
      "/var/lib/headscale"
    ];
  };
}
