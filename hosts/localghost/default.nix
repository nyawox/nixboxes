# { lib, ... }:
{
  # uncomment this in reinstallation
  # services.openssh.openFirewall = lib.mkForce true;

  modules = {
    sysconf = {
      sshluks.enable = true;
      bluetooth.enable = false;
      # apparently qemu don't like mac randomization
      hardening.overrides.compatibility.disable-eth-mac-rando = true;
    };
    services = {
      tailscale = {
        enable = true;
        setFlags = [ "--advertise-exit-node" ];
      };
      homepage.enable = true;
      acme.enable = true;
      caddy.enable = true;
      headscale.enable = true;
      searxng.enable = true;
      open-webui.enable = true;
      headplane.enable = true;
      netdata = {
        enable = true;
        apikey = "c96533b8-4709-48ea-862e-cca0871b72a4";
      };
      frp.enable = true;
    };
    desktop = {
      pipewire.enable = false;
      plymouth.enable = false;
    };
  };

  tmpfsroot = {
    enable = true;
    size = "512M";
  };
  disk = {
    encryption.enable = true;
    device = "/dev/vda";
  };
  esp = {
    mbr = true;
    size = "256M";
  };

  # messes up with vnc
  psilocybin.enable = false;

  # allow ip forwarding for tailscale
  networking.firewall.extraCommands = ''
    iptables -P FORWARD ACCEPT
  '';
  modules.sysconf.hardening.overrides.compatibility.allow-ip-forward = true;
  boot = {
    kernelParams = [ "ip=64.112.124.245" ];
    # Kernel modules required to boot on virtual machine
    # Make sure to include ethernet module to remote unlock luks
    initrd.availableKernelModules = [
      "ata_piix"
      "uhci_hcd"
      "virtio_pci"
      "sr_mod"
      "sd_mod"
      "virtio_blk"
      "virtio-net"
      "virtio_mmio virtio_scsi"
      "9p"
      "9pnet_virtio"
    ];
    initrd.kernelModules = [
      "virtio_balloon"
      "virtio_console"
      "virtio_rng"
    ];
  };
}
