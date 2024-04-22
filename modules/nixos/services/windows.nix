# stolen from here https://github.com/dockur/windows/issues/261
# WEB access: http://127.0.0.1:8006/
{
  config,
  lib,
  pkgs,
  username,
  ...
}:
with lib; let
  cfg = config.modules.services.windows;
  app = "windows";
  dataDir = "/var/lib/${app}";
  ipContainerNetwork = "10.89.53.1/24"; # choose an available network `ip a | grep podman`
  ipContainer1 = "10.89.53.11"; # manual networking is more reliable, trust me
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
    virtualisation.oci-containers.containers.${app} = {
      image = "docker.io/dockurr/windows:latest"; # <https://hub.docker.com/r/dockurr/windows/tags>
      user = "root:root";
      autoStart = false; # start it when needed with `sudo systemctl start podman-windows.service`
      environment = {
        # iPhone
        # ARGUMENTS = "-device usb-host,vendorid=0x05ac,productid=0x12a8";
        ARGUMENTS = "-device usb-host,hostbus=1,hostport=4";
        VERSION = "win11";
        RAM_SIZE = "8G";
        CPU_CORES = "12";
        DISK_SIZE = "100G";
      };
      ports = [
        # right side is the port on guest
        "127.0.0.1:8006:8006"
        "5050:8080" # sidejitserver
        "49151:49151" # sidejitserver
        # "127.0.0.1:123:123/tcp" # altserver
        # "127.0.0.1:3689:3689/tcp" # altserver
        # "127.0.0.1:123:123/udp" # altserver
        # "127.0.0.1:3689:5353/udp" # altserver
        "127.0.0.1:3389:3389/tcp"
        "127.0.0.1:3389:3389/udp"
      ];
      extraOptions = [
        "--device=/dev/kvm"
        "--device=/dev/net/tun"
        "--device=/dev/vhost-net"
        "--device=/dev/bus/usb"
        "--cap-add=NET_ADMIN"
        "--cap-add=NET_RAW"
        "--network=${app}"
        "--ip=${ipContainer1}"
      ];
      volumes = ["${dataDir}:/storage" "/home/${username}/winshare:/storage/shared"];
    };
    systemd.tmpfiles.rules = ["d '${dataDir}' 0700 root root - -"];
    systemd.services."podman-${app}".preStart = ''
      ${pkgs.podman}/bin/podman network exists ${app} || \
      ${pkgs.podman}/bin/podman network create ${app} \
      --subnet=${ipContainerNetwork}
    '';
    networking.nftables.enable = lib.mkForce false;
    networking.firewall.extraCommands = ''
      iptables -A INPUT -p tcp --destination-port 53 -s ${ipContainerNetwork} -j ACCEPT
      iptables -A INPUT -p udp --destination-port 53 -s ${ipContainerNetwork} -j ACCEPT
    '';
    networking.firewall.allowedTCPPorts = [5050];
    environment.persistence."/persist".directories = mkIf config.modules.sysconf.impermanence.enable ["/var/lib/${app}"];
    environment.persistence."/persist".users."${username}".directories = mkIf config.modules.sysconf.impermanence.enable ["winshare"];
  };
}
