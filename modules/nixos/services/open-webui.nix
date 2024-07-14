{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.services.open-webui;
  ipSubnet = "172.27.0.0/16";
in {
  options = {
    modules.services.open-webui = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
      port = mkOption {
        type = types.int;
        default = 11454;
      };
    };
  };
  config = mkIf cfg.enable {
    virtualisation.arion.projects.open-webui.settings = {
      project.name = "open-webui";
      networks = {
        default = {
          name = "open-webui";
          ipam = {
            config = [{subnet = ipSubnet;}];
          };
        };
      };

      services.open-webui = {
        service = {
          image = "ghcr.io/open-webui/open-webui:main";
          container_name = "open-webui";
          environment = {
            OLLAMA_BASE_URL = "http://localpost.nyaa.nixlap.top:11451";
            ANONYMIZED_TELEMETRY = "False";
            DO_NOT_TRACK = "True";
            SCARF_NO_ANALYTICS = "True";
          };
          volumes = ["/var/lib/open-webui:/app/backend/data"];
          restart = "unless-stopped";
          ports = [
            "127.0.0.1:${builtins.toString cfg.port}:8080"
          ];
          labels."io.containers.autoupdate" = "registry";
        };
      };
    };
    systemd.services.arion-open-webui = {
      wants = ["network-online.target"];
      after = ["network-online.target"];
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
    environment.persistence."/persist".directories = mkIf config.modules.sysconf.impermanence.enable [
      "/var/lib/open-webui"
    ];
  };
}
