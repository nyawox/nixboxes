{
  config,
  lib,
  pkgs,
  username,
  inputs,
  ...
}: {
  imports = [inputs.madness.nixosModules.madness];
  modules = {
    sysconf = {
      wifi.enable = true;
      networkd.enable = false;
      networkmanager.enable = true;
      # secureboot.enable = true;
      sshluks.enable = true;
    };
    services = {
      tailscale.enable = true;
      tang.enable = true;
      netdata = {
        enable = true;
        apikey = "2e117745-b8b7-4f7b-8b50-e4df187e36ea";
      };
      avahi.enable = true;
      nfs-server = {
        enable = true;
        nixboxes = true;
      };
      nfs-client.calibre = true;
      sunshine.enable = true;
      minecraft-server.enable = true;
      flatpak = {
        enable = true;
        fonts = true;
      };
      firejail.enable = true;
      windows.enable = true;
      airplay.enable = true;
      altserver.enable = true;
      tor.enable = true;
      v2ray.enable = true;
      redroid.enable = true;
    };
    desktop = {
      niri.enable = true;
      greetd.enable = true;
      piper.enable = true;
      headsetcontrol.enable = true;
      gaming.enable = true;
    };
    virtualisation = {
      waydroid.enable = true;
      arion.enable = true;
    };
  };

  sops.secrets = {
    "switch" = {
      sopsFile = ../../secrets/switch.env;
      format = "dotenv";
      owner = config.users.users.${username}.name;
      inherit (config.users.users.${username}) group;
    };
    hdd-crypto.sopsFile = ../../secrets/hdd-crypto.yaml;
  };
  madness.enable = true;
  services = {
    # github:nyawox/nixtendo-switch
    switch-boot.enable = true;
    switch-presence = {
      enable = true;
      environmentFile = config.sops.secrets.switch.path;
    };
    irqbalance.enable = true;
    gvfs.enable = true;
    tumbler.enable = true;
    ratbagd.enable = true;
    # sysdvr
    udev.extraRules =
      /*
      rules
      */
      ''
        SUBSYSTEM=="usb", ATTRS{idVendor}=="18d1", ATTRS{idProduct}=="4ee0", MODE="0666"
      '';
    pipewire.extraConfig.pipewire."10-loopback-line_in" = {
      "context.modules" = lib.singleton {
        name = "libpipewire-module-loopback";
        args = {
          "capture.props" = {
            "audio.position" = [
              "FL"
              "FR"
            ];
            "node.name" = "Line In";
            "node.target" = "alsa_input.pci-0000_0e_00.3.analog-stereo";
          };
          "playback.props" = {
            "audio.position" = [
              "FL"
              "FR"
            ];
            "node.name" = "Loopback-line_in";
            "media.class" = "Stream/Output/Audio";
            "monitor.channel-volumes" = true;
          };
        };
      };
    };
  };

  disk.device = "/dev/nvme0n1";

  psilocybin.devices = ["/dev/input/by-id/usb-Topre_Corporation_HHKB_Professional-event-kbd"];

  gtk.iconCache.enable = true;

  programs = {
    gnome-disks.enable = true;
    adb.enable = true;
  };

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [9090];
  # networking.firewall.allowedUDPPorts = [ ... ];

  security.lockKernelModules = false;
  security.protectKernelImage = false;

  boot = {
    kernelPackages = pkgs.linuxPackages_xanmod_latest;
    kernelParams = [
      "amdgpu.lockup_timeout=5000" # set timeout duration for detecting and handling gpu lockups
      "amdgpu.ppfeaturemask=0xffffffff" # enable overclocking amdgpu
      # these options below vastly reduced freeze while gpu is under heavy load
      "amdgpu.audio=0"
      "amdgpu.sg_display=0"
      "amdgpu.runpm=0"
      "amdgpu.bapm=0"
      "amdgpu.aspm=0"
      "pcie_aspm=off"
    ];
    loader.efi.canTouchEfiVariables = true;
    loader.efi.efiSysMountPoint = "/boot";

    initrd = {
      verbose = false;
      availableKernelModules = [
        "nvme"
        "xhci_pci"
        "ahci"
        "usbhid"
        "sd_mod"
      ];
      kernelModules = ["amdgpu"];
    };
  };

  hardware = {
    cpu.amd.updateMicrocode = true;

    graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        vaapiVdpau
        libvdpau-va-gl
      ];
    };
    xone.enable = true;
  };

  systemd.packages = [pkgs.lact];
  fileSystems."/mnt/hdd".device = "/dev/mapper/hdd";
  environment = {
    # ios tweak dev
    variables.THEOS = "/home/${username}/theos";
    # use crypttab for non boot required luks devices
    etc."crypttab".text = ''
      hdd /dev/disk/by-uuid/b347d514-3e34-4bb1-8a72-630176f48783 ${config.sops.secrets.hdd-crypto.path}
    '';
    systemPackages = [pkgs.lact];

    persistence."/persist" = {
      directories = lib.mkIf config.modules.sysconf.impermanence.enable [
        {
          directory = "/nixboxes";
          user = "${username}";
          group = "users";
          mode = "757";
        }
        "/etc/lact"
      ];
      users."${username}" = lib.mkIf config.modules.sysconf.impermanence.enable {
        directories = [
          "theos"
          "Games"
          "PopTracker"
          "invokeai"
          ".local/share/zathura"
          ".local/share/remmina"
          ".local/share/TelegramDesktop"
          ".config/heroic"
          ".config/remmina"
          ".config/Signal"
          ".config/obsidian"
          ".config/vivaldi"
          ".config/onlyoffice"
          ".config/calibre"
          ".android"
        ];
      };
    };
  };
}
