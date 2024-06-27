{
  pkgs,
  lib,
  ...
}: {
  # Building man-cache on qemu is very slow.
  documentation.man.generateCaches = false;

  modules = {
    sysconf = {
      bluetooth.enable = true;
      sshluks.enable = true;
    };
    desktop = {
      pipewire.enable = false;
      plymouth.enable = false;
    };
    services = {
      tailscale.enable = true;
      netdata = {
        enable = true;
        apikey = "a73b169d-3a46-46d1-b8d5-48bd53933f9a";
      };
      ntfy-sh.enable = true;
      authelia.enable = true;
      avahi.enable = true;
      home-assistant.enable = true;
      postgresql.enable = true;
      vaultwarden.enable = true;
      node-red.enable = true;
      redis.enable = true;
      couchdb.enable = true;
      ollama.enable = true;
      firetv-launcher.enable = true;
    };
  };
  services.switch-boot.enable = true;

  disk.device = "/dev/sdb";

  boot = {
    # Use the systemd-boot EFI boot loader.
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = false;

    initrd.availableKernelModules = [
      "usbhid"
      # "sr_mod" # sd card and internal emmc storage
    ];
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
      "xhci_pci"

      # PCIE/NVMe/SATA
      "pcie_rockchip_host"
      "phy_rockchip_pcie"
      # "nvme"
      "ahci" # sata devices on modern ahci controllers
      "sd_mod" # scsi, sata and pata devices

      # ethernet, required for luks ssh
      "stmmac"
      "dwmac_rk"

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
  psilocybin.enable = false;

  networking.interfaces.wlu1.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
  powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";
}
