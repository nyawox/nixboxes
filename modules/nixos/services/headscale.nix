{
  config,
  lib,
  inputs,
  ...
}:
with lib;
let
  cfg = config.modules.services.headscale;
  domain = "hs.nixlap.top";
  derpPort = 3478;
in
{
  options = {
    modules.services.headscale = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };
  config = mkIf cfg.enable {
    nixpkgs.overlays = [ inputs.headscale.overlay ];
    sops.secrets.headscale_acls = {
      sopsFile = ../../../secrets/headscale_acls.yaml;
      owner = "headscale";
      group = "headscale";
      format = "yaml";
    };
    services = {
      headscale = {
        enable = true;
        address = "0.0.0.0";
        port = 8085;
        settings = {
          dns = {
            magic_dns = true;
            base_domain = "hsnet.nixlap.top";
            nameservers.global = [
              # AdGuard Home
              "100.64.0.2" # localpost
              "100.64.0.3" # localtoast
              "127.0.0.1" # keep localhost, otherwise sometimes it fails to connect
              # Add quad9 back when adguard home is down(e.g. reinstalling headscale)
              # "9.9.9.9"
              # "149.112.112.112"
            ];
          };
          logtail.enabled = false;
          policy.path = config.sops.secrets.headscale_acls.path;
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

    environment.systemPackages = [ config.services.headscale.package ];
    networking.firewall.allowedTCPPorts = [
      80
      443
    ];
    networking.firewall.allowedUDPPorts = [ derpPort ];

    environment.persistence."/persist".directories = mkIf config.modules.sysconf.impermanence.enable [
      "/var/lib/headscale"
    ];
  };
}
