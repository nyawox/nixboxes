{
  lib,
  config,
  pkgs,
  ...
}: {
  modules = {
    sysconf = {
      wifi.enable = true;
      laptop.enable = true;
    };
    services = {
      tailscale.enable = true;
      netdata = {
        enable = true;
        apikey = "f17bc57e-969e-488c-ae8a-2ea69e319b35";
      };
      avahi.enable = true;
      nfs-client.nixboxes = true;
      flatpak = {
        enable = true;
        fonts = true;
      };
    };
    desktop = {
      cosmic.enable = true;
      polkit.enable = true;
    };
  };

  security.lockKernelModules = false;
  security.protectKernelImage = false;
  boot.kernelPackages = pkgs.linuxPackages_cachyos;

  services.switch-boot.enable = true;

  tmpfsroot = {
    enable = true;
    size = "1G";
  };
  disk.encryption = {
    enable = true;
  };
  disk.device = "/dev/sda";
  psilocybin = {
    jis.enable = true;
    devices = ["/dev/input/by-path/platform-i8042-serio-0-event-kbd"];
  };

  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  boot.initrd.kernelModules = ["i915"];

  environment.variables = {
    VDPAU_DRIVER = lib.mkIf config.hardware.opengl.enable (lib.mkDefault "va_gl");
  };

  hardware.graphics.extraPackages = with pkgs; [
    (
      if (lib.versionOlder (lib.versions.majorMinor lib.version) "23.11")
      then vaapiIntel
      else intel-vaapi-driver
    )
    libvdpau-va-gl
    intel-media-driver
  ];

  programs.gnome-disks.enable = true;
}
