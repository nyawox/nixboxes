{
  lib,
  config,
  pkgs,
  ...
}: {
  modules = {
    sysconf = {
      wifi.enable = true;
      secureboot.enable = true;
      laptop.enable = true;
    };
    services = {
      tailscale.enable = true;
      avahi.enable = true;
      nfs-client.nixboxes = true;
    };
    desktop = {
      hyprland.enable = true;
      greetd.enable = true;
      swaylock.enable = true;
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
  keyboardlayout.jis = true;

  hardware.cpu.intel.updateMicrocode =
    lib.mkDefault config.hardware.enableRedistributableFirmware;

  boot.initrd.kernelModules = ["i915"];

  environment.variables = {
    VDPAU_DRIVER = lib.mkIf config.hardware.opengl.enable (lib.mkDefault "va_gl");
  };

  hardware.opengl.extraPackages = with pkgs; [
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
