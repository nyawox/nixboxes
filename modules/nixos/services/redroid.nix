{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.modules.services.redroid;
  ipSubnet = "172.27.0.0/16";
in
{
  options = {
    modules.services.redroid = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };
  config = mkIf cfg.enable {
    modules.virtualisation.arion.enable = mkForce true;
    virtualisation.arion.projects.redroid.settings = {
      project.name = "redroid";
      networks = {
        default = {
          name = "redroid";
          ipam = {
            config = [ { subnet = ipSubnet; } ];
          };
        };
      };
      services.redroid.service = {
        image = "redroid/redroid:14.0.0-latest";
        restart = "unless-stopped";
        privileged = true;
        ports = [ "0.0.0.0:5555:5555" ]; # adb
        volumes = [ "/var/lib/redroid:/data" ];
        devices = [ "/dev/dri/renderD128" ];
        command = [
          "androidboot.use_memfd=true"
          "androidboot.redroid_fps=120"
          "androidboot.redroid_dpi=264"
          "androidboot.redroid_width=720"
          "androidboot.redroid_height=1440"
          "androidboot.redroid_gpu_mode=host"
          "androidboot.redroid_net_ndns=192.168.0.185"
        ];
      };
    };
    systemd.services.arion-redroid.wantedBy = mkForce [ ]; # Don't autostart DE/WM becomes unable to launch
    networking = {
      nftables.enable = mkForce false;
      firewall.extraCommands =
        # bash
        ''
          iptables -A INPUT -p tcp --destination-port 53 -s ${ipSubnet} -j ACCEPT
          iptables -A INPUT -p udp --destination-port 53 -s ${ipSubnet} -j ACCEPT
        '';
    };
    environment.persistence."/persist".directories = mkIf config.modules.sysconf.impermanence.enable [
      "/var/lib/redroid"
    ];
  };
}
