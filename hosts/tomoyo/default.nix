_: {
  modules = {
    sysconf = {
      sshluks.enable = true;
      bluetooth.enable = false;
    };
    services = {
      tailscale.enable = true;
      homepage.enable = true;
      linkding.enable = true;
      netdata = {
        enable = true;
        receiver = true;
        apikey = "c96533b8-4709-48ea-862e-cca0871b72a4";
      };
      open-webui.enable = true;
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

  security.lockKernelModules = false; # fix podman netlink issue

  # messes up with vnc
  psilocybin.enable = false;

  boot = {
    kernelParams = ["ip=64.112.124.245"];
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
