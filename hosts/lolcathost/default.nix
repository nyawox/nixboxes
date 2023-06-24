{
  config,
  lib,
  username,
  inputs,
  pkgs,
  ...
}:
{
  imports = [ inputs.madness.nixosModules.madness ];
  modules = {
    sysconf = {
      wifi.enable = true;
      secureboot.enable = true;
      tpm2.enable = true;
      sshluks.enable = true;
      cachyos.enable = true; # includes acs patch by default. probably not great for security but... what's the alternative
      nvidia = {
        enable = true;
        modeSet = true;
        prime = true;
      };
      amdgpu = {
        enable = true;
        modeSet = true;
      };
    };
    services = {
      tailscale = {
        enable = true;
        notifier = true;
      };
      tang.enable = true;
      netdata = {
        enable = true;
        apikey = "2e117745-b8b7-4f7b-8b50-e4df187e36ea";
      };
      avahi.enable = true;
      # kicksecure breaks nfs, and i don't use anymore
      # nfs-server = {
      #   enable = true;
      #   nixboxes = true;
      # };
      # nfs-client.calibre = true;
      # sunshine.enable = true; # edid-decode failing to build
      minecraft-server.enable = true;
      flatpak = {
        enable = true;
        fonts = true;
      };
      firejail.enable = true;
      airplay.enable = true;
      altserver.enable = true;
      tor.enable = true;
      v2ray.enable = true;
      redroid.enable = true;
      gvfs.enable = true;
      ollama.enable = true;
    };
    desktop = {
      niri = {
        enable = true;
        default = true;
      };
      greetd.enable = true;
      piper.enable = true;
      headsetcontrol.enable = true;
      gaming.enable = true;
    };
    virtualisation = {
      waydroid.enable = false;
      arion.enable = true;
      windows = {
        enable = true;
        iso = {
          enable = true;
          shrink = true;
        };
        gpuPassthrough = {
          enable = true;
          # iommu group 13
          nvidia.gpuid = "pci_0000_01_00_0";
          nvidia.audioid = "pci_0000_01_00_1";
        };
      };
      macos = {
        enable = true;
        gpuPassthrough = {
          enable = true;
          # iommu group 17
          amd.gpuid = "pci_0000_0d_00_0";
        };
      };
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
    kmscon.enable = lib.mkForce false;
    irqbalance.enable = true;
    tumbler.enable = true;
    ratbagd.enable = true;
    udev.extraRules =
      # rules
      ''
        # sysdvr
        SUBSYSTEM=="usb", ATTRS{idVendor}=="18d1", ATTRS{idProduct}=="4ee0", MODE="0666"
        # create a separate symlink for touchpad, so i can passthrough to vm (sadly the result wasn't great)
        SUBSYSTEM=="input", ATTRS{name}=="Wacom Bamboo 16FG 4x5 Finger", KERNEL=="event*", SYMLINK+="touchypaddy"

      '';

    # route from line in to line out, mainly for kvm switcher, and vm guests

    # pipewire.extraConfig.pipewire."10-loopback-line_in" = {
    #   "context.modules" = lib.singleton {
    #     name = "libpipewire-module-loopback";
    #     args = {
    #       "capture.props" = {
    #         "audio.position" = [
    #           "FL"
    #           "FR"
    #         ];
    #         "node.name" = "Line In";
    #         "node.target" = "alsa_input.pci-0000_0e_00.3.analog-stereo";
    #       };
    #       "playback.props" = {
    #         "audio.position" = [
    #           "FL"
    #           "FR"
    #         ];
    #         "node.name" = "Loopback-line_in";
    #         "media.class" = "Stream/Output/Audio";
    #         "monitor.channel-volumes" = true;
    #       };
    #     };
    # };
    # };
  };

  disk.device = "/dev/nvme0n1";

  # /run/kanata-psilocybin/psilocybin
  psilocybin.devices = [ "/dev/input/by-id/usb-Topre_Corporation_HHKB_Professional-event-kbd" ];

  gtk.iconCache.enable = true;

  programs = {
    gnome-disks.enable = true;
    adb.enable = true;
  };

  networking = {
    # Open ports in the firewall.
    firewall.allowedTCPPorts = [ 9090 ];
    # firewall.allowedUDPPorts = [ ... ];
    interfaces.enp9s0.useDHCP = lib.mkDefault true; # not sure if it's still necessary
  };

  modules.sysconf.hardening.overrides = {
    desktop = {
      allow-unprivileged-userns = true; # used in bubblewrap
      usbguard-notifier = true;
      # usbguard-allow-at-boot = true; # enable this to generate usbguard rules the first time
    };
    compatibility.allow-binfmt-misc = true; # required for aarch64 compilation on nix
    performance.allow-smt = true; # enable smt to increase performance
  };

  boot = {
    binfmt.emulatedSystems = [ "aarch64-linux" ]; # aarch64 emulation
    loader.efi.canTouchEfiVariables = true;
    loader.efi.efiSysMountPoint = "/boot";
    # patch kernel to allow to specify boot vga device
    kernelPatches = [
      {
        name = "vgaarb-bootdev";
        patch = pkgs.fetchurl {
          url = "lore.kernel.org/lkml/8498ea9f-2ba9-b5da-7dc4-1588363f1b62@absolutedigital.net/t.mbox.gz";
          sha256 = "086gifmmnrvl3qdmj9a14zr19mw38j8c8kl3glcj08qd114yxnal";
        };
      }
    ];
    # default to amd gpu, then fallback if not avaliable
    kernelParams = [
      "vgaarb.bootdev=0d:00.0"
    ];

    initrd = {
      verbose = false;
      availableKernelModules = [
        "nvme"
        "xhci_pci"
        "ahci"
        "usbhid"
        "sd_mod"
      ];
    };
  };

  powerManagement = {
    enable = true;
    cpuFreqGovernor = "performance";
  };

  hardware = {
    cpu.amd.updateMicrocode = true;
    # make sure to connect on xhci port, it's broken rn on usb 2.0
    xone.enable = true;
  };

  fileSystems."/mnt/hdd".device = "/dev/mapper/hdd";
  environment = {
    # ios tweak dev
    variables.THEOS = "/home/${username}/theos";
    # scudo causing issue when building package
    memoryAllocator.provider = "libc";
    # use crypttab for non boot required luks devices
    etc."crypttab".text = ''
      hdd /dev/disk/by-uuid/b347d514-3e34-4bb1-8a72-630176f48783 ${config.sops.secrets.hdd-crypto.path}
    '';

    persistence."/persist" = {
      directories = lib.mkIf config.modules.sysconf.impermanence.enable [
        {
          directory = "/nixboxes";
          user = "${username}";
          group = "users";
          mode = "757";
        }
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
