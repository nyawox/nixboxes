# currently running non-stable revision,
# see the changelog here: https://github.com/juanfont/headscale/blob/main/CHANGELOG.md
{
  config,
  lib,
  inputs,
  ...
}:
with lib; let
  cfg = config.modules.services.headscale;
  domain = "hs.nixlap.top";
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
    nixpkgs.overlays = [inputs.headscale.overlay];
    services = {
      headscale = {
        enable = true;
        address = "0.0.0.0";
        port = 8085;
        settings = let
          certDir = config.security.acme.certs."nixlap.top".directory;
        in {
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
            tls_key_path = "${certDir}/key.pem";
            tls_cert_path = "${certDir}/cert.pem";
          };
          logtail.enabled = false;
          acl_policy_path = "/var/lib/headscale/acl_policy.json";
          server_url = "https://${domain}";
          prefixes = {
            v6 = "fd7a:115c:a1e0::/48";
            v4 = "100.64.0.0/10";
          };
          database = {
            type = "sqlite3";
            sqlite = {
              path = "/var/lib/headscale/db.sqlite";
              write_ahead_log = true;
            };
          };

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
          reverse_proxy /admin* http://127.0.0.1:9191
          reverse_proxy * http://[::1]:8085
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
