{
  pkgs,
  lib,
  self,
  inputs,
  stateVersion,
  hostname,
  username,
  platform,
  deploy,
  ...
}:
with lib;
{
  config = {
    networking.hostName = hostname;
    nixpkgs.hostPlatform = platform;
    var.username = username;
    modules.deploy.enable = deploy;

    boot = {
      loader = {
        # Use the systemd-boot EFI boot loader.
        systemd-boot.enable = mkDefault true;
        systemd-boot.configurationLimit = mkDefault 15;
        efi.canTouchEfiVariables = mkDefault false;
        timeout = mkDefault 0;
      };

      kernelModules = [ "lkrg" ];
      kernelParams = [ "libahci.ignore_sss=1" ];

      initrd.systemd.enable = mkDefault true;

      consoleLogLevel = mkDefault 7;
    };

    modules.sysconf.hardening.overrides = {
      security.disable-intelme-kmodules = mkDefault true; # disable intel me related kernel modules
      security.disable-module-loading = mkForce false; # many services (podman, nftables) rely on this and may cause boot to fail
    };

    security.forcePageTableIsolation = mkDefault true;
    security.virtualisation.flushL1DataCache = mkDefault "always";

    hardware.enableRedistributableFirmware = mkDefault true;

    environment = {
      memoryAllocator.provider = mkDefault "scudo";
      variables.SCUDO_OPTIONS = mkDefault "ZeroContents=1";
      variables.EDITOR = "hx";
      systemPackages = with pkgs; [
        helix
        git
        wget
        # backup
        restic
      ];
    };
    programs = {
      command-not-found.dbPath = inputs.programsdb.packages.${pkgs.system}.programs-sqlite;

      # Otherwise home-manager will fail https://github.com/nix-community/home-manager/issues/3113
      dconf.enable = true;

      gnupg.agent = {
        enable = true;
        enableSSHSupport = true;
      };

      # Some programs need SUID wrappers, can be configured further or are
      # started in user sessions.
      mtr.enable = true;
    };

    networking.nftables.enable = true;

    users = {
      users = {
        "${username}" = {
          group = "wheel";
          isNormalUser = true;
          description = "nyan";
          # Default password is alpinerickroll
          password = lib.mkDefault "alpinerickroll";
          extraGroups = [
            "networkmanager"
            "libvirtd"
            "audio"
            "input"
            "video"
            "adbusers"
            "netdev"
            "uinput"
          ];
        };
        # set root password to null
        root.password = lib.mkDefault null;
      };
      groups.wheel = {
        members = [
          "${username}"
          "root"
        ];
      };
      # groups.uinput = {members = ["${username}"];}; # required for kanata
      mutableUsers = false;

      defaultUserShell = pkgs.nushell;
    };
    psilocybin = {
      enable = lib.mkDefault true;
      package = lib.mkDefault pkgs.kanata;
    };

    services = {
      dbus = {
        enable = true;
        implementation = "broker";
      };
      usbguard.IPCAllowedUsers = [
        "root"
        "${username}"
      ];
    };

    # Boot faster
    systemd.services.systemd-udev-settle.enable = false;

    system.stateVersion = stateVersion;
    # Include git commit hash on boot label
    system.configurationRevision = lib.mkIf (self ? rev) self.rev;
  };
}
