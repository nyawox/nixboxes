{
  config,
  lib,
  pkgs,
  username,
  ...
}: {
  modules = {
    sysconf = {
      wifi.enable = true;
      # secureboot.enable = true;
      sshluks.enable = true;
    };
    services = {
      tailscale.enable = true;
      avahi.enable = true;
      nfs-server.enable = true;
      sunshine.enable = true;
      xmrig.enable = true;
      minecraft-server.enable = true;
      flatpak.enable = true;
      influxdb.enable = true;
      windows.enable = true;
      airplay.enable = true;
    };
    desktop = {
      # niri.enable = true;
      # swaylock.enable = true;
      # greetd.enable = true;
      # polkit.enable = true;
      cosmic.enable = true;
    };
    virtualisation.waydroid.enable = true;
    virtualisation.waydroid.rdp = true;
  };

  sops.secrets."switch" = {
    sopsFile = ../../secrets/switch.env;
    format = "dotenv";
    owner = config.users.users.${username}.name;
    inherit (config.users.users.${username}) group;
  };
  services = {
    # github:nyawox/nixtendo-switch
    switch-boot.enable = true;
    switch-presence = {
      enable = true;
      environmentFile = config.sops.secrets.switch.path;
    };
    irqbalance.enable = true;
    usbmuxd.enable = true;
    gvfs.enable = true;
    tumbler.enable = true;
    ratbagd.enable = true;
    # sysdvr
    udev.extraRules = ''
      SUBSYSTEM=="usb", ATTRS{idVendor}=="18d1", ATTRS{idProduct}=="4ee0", MODE="0666"
    '';
    pipewire.extraConfig.pipewire."10-loopback-line_in" = {
      "context.modules" = [
        {
          name = "libpipewire-module-loopback";
          args = {
            "capture.props" = {
              "audio.position" = ["FL" "FR"];
              "node.name" = "Line In";
              "node.target" = "alsa_input.pci-0000_0e_00.3.analog-stereo";
            };
            "playback.props" = {
              "audio.position" = ["FL" "FR"];
              "node.name" = "Loopback-line_in";
              "media.class" = "Stream/Output/Audio";
              "monitor.channel-volumes" = true;
            };
          };
        }
      ];
    };
  };

  disk.device = "/dev/nvme0n1";

  fileSystems."/mnt/hdd" = {
    device = "/dev/sdb1";
    fsType = "btrfs";
    noCheck = true;
    options = [
      "nofail"
      "compress=zstd"
    ];
  };

  gtk.iconCache.enable = true;

  programs = {
    gnome-disks.enable = true;
    adb.enable = true;
    ns-usbloader.enable = true;
    honkers-railway-launcher.enable = true;
    kdeconnect = {
      enable = true;
      # broken
      # https://github.com/NixOS/nixpkgs/pull/269663
      # package = pkgs.valent;
    };

    gamemode.enable = true;
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];

  security.lockKernelModules = false;
  security.protectKernelImage = false;

  boot = {
    supportedFilesystems = ["ntfs"];
    kernelPackages = pkgs.linuxPackages_cachyos;
    extraModprobeConfig = ''
      options usbhid quirks=0x046D:0x0A38:0x0004
      options kvm_intel nested=1
      options kvm_intel emulate_invalid_guest_state=0
      options kvm ignore_msrs=1
    '';

    binfmt.emulatedSystems = ["aarch64-linux"];

    kernelParams = [
      "allow_discards"
      "vt.global_cursor_default=0"
      "amdgpu.ppfeaturemask=0xffffffff"
      "amd_iommu=on"
      "iommu=pt"
      "pcie_acs_override=downstream,multifunction"
      # "video=efifb:off,vesafb:off"
      # "modeset=1"
    ];
    loader.efi.canTouchEfiVariables = true;
    loader.efi.efiSysMountPoint = "/boot";

    initrd = {
      verbose = false;
      availableKernelModules = ["nvme" "xhci_pci" "ahci" "usbhid" "sd_mod"];
      kernelModules = ["amdgpu"];
    };
    kernelModules = [
      "kvm-amd"
      "vfio"
      "vfio-pci"
      "vfio_iommu_type1"
      "vfio_virqfd"
      # "vendor-reset"
      "uhid"
    ];
    # extraModulePackages = with config.boot.kernelPackages; [
    # vendor-reset
    # ];
  };

  systemd.extraConfig = ''
    DefaultTimeoutStartSec=30s
    DefaultTimeoutStopSec=10s
  '';

  hardware = {
    cpu.amd.updateMicrocode = true;

    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
      extraPackages = with pkgs; [vaapiVdpau libvdpau-va-gl];
    };
    xpadneo.enable = true;
    # xone.enable = true;
  };

  environment.persistence."/persist" = {
    directories = lib.mkIf config.modules.sysconf.impermanence.enable [
      {
        directory = "/nixboxes";
        user = "${username}";
        group = "users";
        mode = "757";
      }
    ];
    users."${username}" = {
      directories = [
        "PopTracker"
        "invokeai"
        ".local/share/Steam"
        ".local/share/yuzu"
        ".local/share/Cemu"
        ".local/share/dolphin-emu"
        ".config/dolphin-emu"
        ".local/share/remmina"
        ".local/share/lutris"
        ".local/share/PrismLauncher/instances"
        ".local/share/PrismLauncher/logs"
        ".local/share/PrismLauncher/translations"
        ".local/share/PrismLauncher/meta"
        ".config/rpcs3"
        ".config/heroic"
        ".config/lutris"
        ".config/remmina"
        ".config/Element"
      ];
    };
  };
}
