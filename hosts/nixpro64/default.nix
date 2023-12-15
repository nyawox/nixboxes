{
  pkgs,
  lib,
  ...
}: {
  # Building man-cache on qemu is very slow.
  documentation.man.generateCaches = false;

  modules = {
    sysconf = {
      wifi.enable = true;
      bluetooth.enable = false;
    };
    desktop = {
      pipewire.enable = false;
      plymouth.enable = false;
    };
    services = {
      nfs-client.backups = true;
      tailscale.enable = true;
      avahi.enable = true;
      home-assistant.enable = true;
      postgresql.enable = true;
      vaultwarden.enable = true;
      node-red.enable = true;
      influxdb.enable = true;
      redis.enable = true;
      monitoring.loki.enable = true;
    };
  };
  services.switch-boot.enable = true;

  secrets = {
    enable = true;
    enablePassword = true;
  };
  disk.device = "/dev/mmcblk1";

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];

  boot = {
    # Use the systemd-boot EFI boot loader.
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = false;

    initrd.availableKernelModules = ["usbhid"];
    # This list of modules is not entirely minified, but represents
    # a set of modules that is required for the display to work in stage-1.
    # Further minification can be done, but requires trial-and-error mainly.
    initrd.kernelModules = [
      # Rockchip modules
      "rockchip_rga"
      "rockchip_saradc"
      "rockchip_thermal"
      "rockchipdrm"

      # GPU/Display modules
      "analogix_dp"
      "cec"
      "drm"
      "drm_kms_helper"
      "dw_hdmi"
      "dw_mipi_dsi"
      "gpu_sched"
      "panel_edp"
      "panel_simple"
      "panfrost"
      "pwm_bl"

      # USB / Type-C related modules
      "fusb302"
      "tcpm"
      "typec"

      # Misc. modules
      "cw2015_battery"
      "gpio_charger"
      "rtc_rk808"
    ];
    kernelModules = [];
    extraModulePackages = [];
    kernelPackages = pkgs.linuxPackages_latest;

    consoleLogLevel = 7;
  };

  networking.interfaces.wlu1.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
  powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";
}
