# WIP, couldn't manage to fix ssl handshake error
{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.modules.services.altserver;
in
{
  options = {
    modules.services.altserver = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };
  config = mkIf cfg.enable {
    modules.services.usbmuxd.enable = true;
    systemd.services.altserver = {
      enable = true;
      description = "altserver-linux";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = "${getExe pkgs.altserver-linux}";
        Environment = "ALTSERVER_ANISETTE_SERVER=http://localhost:6969";
        Restart = "on-failure";
        RestartSec = "5s";
      };
    };
    networking = {
      nftables.enable = mkForce false;
      firewall = {
        allowedTCPPorts = [
          7788
          13000
        ];
        allowedUDPPorts = [
          7788
          5353
        ];
      };
    };
    environment = {
      systemPackages = with pkgs; [
        altserver-linux
        libimobiledevice
      ];
      persistence."/persist".directories = mkIf config.modules.sysconf.impermanence.enable [
        "/var/lib/anisette"
      ];
    };
    virtualisation.arion.projects.anisette.settings = {
      project.name = "anisette";
      services.anisette.service = {
        image = "dadoum/anisette-v3-server";
        ports = [
          "127.0.0.1:6969:6969"
        ];
        network_mode = "host";
        volumes = [
          "/var/lib/anisette:/home/Alcoholic/.config/anisette-v3/lib/"
        ];
        restart = "always";
        user = "0:0";
      };
    };
  };
}
