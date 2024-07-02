# you must copy stuff such as www directory and nginx conf to /var/lib/aria-onion/
# sudo mount --bind "/mnt/hdd/whatever/directory" /var/lib/aria-onion/downloader/data
{
  config,
  lib,
  inputs,
  ...
}:
with lib; let
  cfg = config.modules.services.aria-onion;
  ipSubnet = "172.40.0.0/16";
in {
  options = {
    modules.services.aria-onion = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
      port = mkOption {
        type = types.int;
        default = 2525;
      };
    };
  };
  config = mkIf cfg.enable {
    sops.secrets.aria-onion = {
      sopsFile = ../../../secrets/aria-onion.env;
      format = "dotenv";
    };
    modules.virtualisation.arion.enable = lib.mkForce true;
    virtualisation.arion.projects.aria-onion-downloader.settings = {
      project.name = "aria-onion-downloader";
      network_mode = "host";
      networks = {
        default = {
          name = "aria-onion-downloader";
          ipam = {
            config = [{subnet = ipSubnet;}];
          };
        };
      };
      services.aria-onion-downloader.service = {
        build.context = inputs.aria-onion.outPath + "/downloader";
        environment = {
          RPCPORT = "6800";
          TORSERVNUM = "99";
        };
        ports = ["127.0.0.1:6800:6800"];
        volumes = [
          "/var/lib/aria-onion/downloader/conf:/conf"
          "/var/lib/aria-onion/downloader/log:/log"
          "/var/lib/aria-onion/downloader/run:/run"
          "/var/lib/aria-onion/downloader/data:/data"
        ];

        env_file = [
          config.sops.secrets.aria-onion.path
        ];
      };
    };
    virtualisation.arion.projects.aria-onion-controller.settings = {
      project.name = "aria-onion-controller";
      services.aria-onion-controller.service = {
        build.context = inputs.aria-onion.outPath + "/controller";
        volumes = [
          "/var/lib/aria-onion/controller/conf:/conf"
          "/var/lib/aria-onion/controller/logs:/logs"
          "/var/lib/aria-onion/controller/www:/var/www"
        ];

        ports = ["127.0.0.1:${builtins.toString cfg.port}:8080"];
      };
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
    environment.persistence."/persist".directories = mkIf config.modules.sysconf.impermanence.enable [
      "/var/lib/aria-onion"
    ];
    systemd.services.arion-aria-onion-downloader.after = ["var-lib-aria-onion.mount"];
    systemd.services.arion-aria-onion-controller.after = ["var-lib-aria-onion.mount"];
  };
}
