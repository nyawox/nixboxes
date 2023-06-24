{
  lib,
  config,
  pkgs,
  username,
  ...
}:
{
  modules = {
    sysconf = {
      wifi.enable = true;
      laptop.enable = true;
      hardening.overrides = {
        compatibility.disable-wifi-mac-rando = true; # breaks local adguardhome dns
        security.disable-intelme-kmodules = true; # reenable intel me modules
      };
    };
    services = {
      tailscale.enable = true;
      tang.enable = true;
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
      firejail.enable = true;
      adguardhome = {
        enable = true;
        openFirewall = true;
        noLog = true;
        slowMode = true;
      };
    };
    desktop = {
      niri.enable = true;
      greetd.enable = true;
    };
  };

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
    devices = [ "/dev/input/by-path/platform-i8042-serio-0-event-kbd" ];
  };

  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  networking.interfaces.enp0s25.useDHCP = lib.mkDefault true;
  networking.interfaces.wlan0.useDHCP = lib.mkDefault true;

  boot = {
    initrd.kernelModules = [ "i915" ];
    extraModprobeConfig = ''
      options iwlwifi power_save=0 uapsd_disable=1 11n_disable=8
      options iwlmvm power_scheme=1
    '';
  };

  environment.variables = {
    VDPAU_DRIVER = lib.mkIf config.hardware.graphics.enable (lib.mkDefault "va_gl");
  };

  hardware.graphics.extraPackages = with pkgs; [
    (
      if (lib.versionOlder (lib.versions.majorMinor lib.version) "23.11") then
        vaapiIntel
      else
        intel-vaapi-driver
    )
    libvdpau-va-gl
    intel-media-driver
  ];

  programs.gnome-disks.enable = true;

  environment.persistence."/persist".users."${username}".directories =
    lib.mkIf config.modules.sysconf.impermanence.enable
      [
        ".config/vivaldi"
        ".config/Signal"
      ];
}
