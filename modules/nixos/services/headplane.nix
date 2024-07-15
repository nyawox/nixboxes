{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.services.headplane;
  ipSubnet = "172.35.0.0/16";
in {
  options = {
    modules.services.headplane = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
      port = mkOption {
        type = types.int;
        default = 9191;
      };
    };
  };
  config = mkIf cfg.enable {
    sops.secrets.headplane = {
      sopsFile = ../../../secrets/headplane.env;
      format = "dotenv";
    };
    modules.virtualisation.arion.enable = mkForce true;
    virtualisation.arion.projects.headplane.settings = {
      project.name = "headplane";
      networks = {
        default = {
          name = "headplane";
          ipam = {
            config = [{subnet = ipSubnet;}];
          };
        };
      };
      services.headplane.service = {
        image = "ghcr.io/tale/headplane:edge";
        volumes = [
          "/var/lib/headscale/acl_policy.json:/etc/headscale/acl_policy.json"
          "/proc:/proc"
        ];
        ports = ["127.0.0.1:${builtins.toString cfg.port}:3000"];
        environment = {
          HEADSCALE_URL = config.services.headscale.settings.server_url;
          HEADSCALE_INTEGRATION = "proc";
          DISABLE_API_KEY_LOGIN = "true";
          ACL_FILE = "/etc/headscale/acl_policy.json";
        };
        env_file = [
          config.sops.secrets.headplane.path
        ];
        labels."io.containers.autoupdate" = "registry";
      };
    };
    networking = {
      nftables.enable = mkForce false;
      firewall.extraCommands =
        /*
        bash
        */
        ''
          iptables -A INPUT -p tcp --destination-port 53 -s ${ipSubnet} -j ACCEPT
          iptables -A INPUT -p udp --destination-port 53 -s ${ipSubnet} -j ACCEPT
        '';
    };
  };
}
