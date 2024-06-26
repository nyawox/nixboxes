{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.services.farfalle;
  ipSubnet = "172.31.0.0/16";
  searxng-url = "http://vultr.nyaa.nixlap.top:8420";
  ollama-url = "http://nixpro64.nyaa.nixlap.top:11451";
in {
  options = {
    modules.services.farfalle = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
      port = mkOption {
        type = types.int;
        default = 3150;
      };
    };
  };
  config = mkIf cfg.enable {
    sops.secrets.farfalle = {
      sopsFile = ../../../secrets/farfalle.env;
      format = "dotenv";
    };
    modules.virtualisation.arion.enable = lib.mkForce true;
    virtualisation.arion.projects.farfalle.settings = {
      project.name = "farfalle";
      networks = {
        default = {
          name = "farfalle";
          ipam = {
            config = [{subnet = ipSubnet;}];
          };
        };
      };
      services.farfalle-backend.service = {
        image = "hajowieland/farfalle-backend:0.0.1";
        network_mode = "host";
        environment = {
          # SEARCH_PROVIDER = "searxng";
          SEARCH_PROVIDER = "tavily";
          SEARXNG_BASE_URL = searxng-url;
          ENABLE_LOCAL_MODELS = "True";
          OLLAMA_HOST = ollama-url;
          OLLAMA_API_BASE = ollama-url;
          POSTGRES_HOST = "nixpro64.nyaa.nixlap.top";
        };
        env_file = [
          config.sops.secrets.farfalle.path
        ];
        restart = "unless-stopped";
      };
      services.farfalle-frontend.service = {
        image = "hajowieland/farfalle-frontend:0.0.1";
        ports = ["${builtins.toString cfg.port}:3000"];
        environment = {
          NEXT_PUBLIC_API_URL = "http://nixpro64.nyaa.nixlap.top:8000";
          NEXT_PUBLIC_LOCAL_MODE_ENABLED = "true";
        };
        restart = "unless-stopped";
        depends_on = ["farfalle-backend"];
      };
    };
    systemd.services.arion-farfalle = {
      wants = ["network-online.target"];
      after = ["network-online.target"];
    };
    networking = {
      nftables.enable = lib.mkForce false;
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
