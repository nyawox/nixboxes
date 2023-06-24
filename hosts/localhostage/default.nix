_: {
  modules = {
    sysconf = {
      wifi.enable = true;
      bluetooth.enable = true;
      sshluks.enable = true;
      clevis.enable = true;
    };
    services = {
      tailscale.enable = true;
      adguardhome = {
        enable = true;
        openFirewall = true;
        noLog = true;
      };
    };
    desktop = {
      pipewire.enable = false;
      plymouth.enable = false;
    };
  };

  tmpfsroot = {
    enable = true;
    size = "256M";
  };
  disk.encryption.enable = true;
  disk.device = "/dev/sdb";
  esp.size = "256M";

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "ehci_pci"
    "usb_storage"
    "uas"
    "sd_mod"
  ];
  boot.initrd.kernelModules = [ ];
}
