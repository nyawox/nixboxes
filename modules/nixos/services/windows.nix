# WEB access: http://127.0.0.1:8006/
{
  config,
  lib,
  username,
  ...
}:
with lib; let
  cfg = config.modules.services.windows;
  ipSubnet = "172.25.0.0/16";
in {
  options = {
    modules.services.windows = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };
  config = mkIf cfg.enable {
    modules.virtualisation.arion.enable = lib.mkForce true;
    virtualisation.arion.projects.windows.settings = {
      project.name = "windows";
      networks = {
        default = {
          name = "windows";
          ipam = {
            config = [{subnet = ipSubnet;}];
          };
        };
      };
      services.windows.service = {
        image = "dockurr/windows:3.06";
        environment = {
          # iPhone
          # ARGUMENTS = "-device usb-host,vendorid=0x05ac,productid=0x12a8";
          # ARGUMENTS = "-device usb-host,hostbus=1,hostport=4";
          VERSION = "win11";
          RAM_SIZE = "8G";
          CPU_CORES = "12";
          DISK_SIZE = "100G";
        };
        ports = [
          # right side is the port on guest
          "127.0.0.1:8006:8006"
          "127.0.0.1:3389:3389/tcp"
          "127.0.0.1:3389:3389/udp"
        ];
        devices = [
          "/dev/kvm"
          "/dev/net/tun"
          "/dev/bus/usb"
          "/dev/vhost-net"
        ];
        capabilities = {
          NET_ADMIN = true;
          NET_RAW = true;
        };
        volumes = [
          "/var/lib/windows:/storage"
          "/home/${username}/winshare:/storage/shared"
          # custom iso
          "/home/${username}/Downloads/iso/tiny11.iso:/storage/custom.iso"
        ];
        stop_grace_period = "2m";
      };
    };
    systemd.services.arion-windows.wantedBy = lib.mkForce []; # Don't autostart
    systemd.tmpfiles.rules = ["d /var/lib/windows ' 0700 root root - -"];
    networking = {
      nftables.enable = lib.mkForce false;
      firewall.extraCommands = ''
        iptables -A INPUT -p tcp --destination-port 53 -s ${ipSubnet} -j ACCEPT
        iptables -A INPUT -p udp --destination-port 53 -s ${ipSubnet} -j ACCEPT
      '';
    };
    environment = {
      shellAliases = {
        winstart = "sudo systemctl start arion-windows";
        winstop = "sudo systemctl stop arion-windows";
        winrestart = "sudo systemctl restart arion-windows";
        winstatus = "systemctl status arion-windows";
        winlog = "journalctl -feu arion-windows";
        winlogs = "journalctl -xeu arion-windows";
        winview = "xdg-open http://127.0.0.1:8006/";
        winrdp = "remmina -c rdp://docker@127.0.0.1:3389";
      };
      persistence."/persist".directories = mkIf config.modules.sysconf.impermanence.enable [
        "/var/lib/windows"
      ];
      persistence."/persist".users."${username}".directories =
        mkIf config.modules.sysconf.impermanence.enable
        ["winshare"];
    };
  };
}
