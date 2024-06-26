_: {
  modules = {
    sysconf = {
      wifi.enable = true;
      bluetooth.enable = true;
      secureboot.enable = true;
    };
    services.tailscale.enable = true;
    desktop = {
      pipewire.enable = false;
      plymouth.enable = false;
    };
  };

  tmpfsroot = {
    enable = true;
    size = "256M";
  };
  disk.encryption = {
    enable = true;
  };
  disk.device = "/dev/sda";
  esp.size = "256M";

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "ehci_pci"
    "usb_storage"
    "uas"
    "sd_mod"
  ];
  boot.initrd.kernelModules = [];
}
