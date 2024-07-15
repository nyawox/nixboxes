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
}: {
  networking.hostName = hostname;
  nixpkgs.hostPlatform = platform;
  var.username = username;
  modules.deploy.enable = deploy;

  boot = {
    loader = {
      # Use the systemd-boot EFI boot loader.
      systemd-boot.enable = lib.mkDefault true;
      systemd-boot.configurationLimit = lib.mkDefault 15;
      efi.canTouchEfiVariables = lib.mkDefault false;
      timeout = lib.mkDefault 0;
    };

    kernelPackages = lib.mkDefault pkgs.linuxPackages_hardened;
    kernelModules = ["lkrg"];
    kernelParams = ["libahci.ignore_sss=1"];

    initrd.systemd.enable = lib.mkDefault true;

    consoleLogLevel = lib.mkDefault 7;
    blacklistedKernelModules = [
      # Obscure network protocols
      "ax25"
      "netrom"
      "rose"

      # Old or rare or insufficiently audited filesystems
      "adfs"
      "affs"
      "bfs"
      "befs"
      "cramfs"
      "efs"
      "erofs"
      "exofs"
      "freevxfs"
      "f2fs"
      "hfs"
      "hpfs"
      "jfs"
      "minix"
      "nilfs2"
      "ntfs"
      "omfs"
      "qnx4"
      "qnx6"
      "sysv"
      "ufs"
    ];
  };

  security.lockKernelModules = lib.mkDefault true;
  security.protectKernelImage = lib.mkDefault true;

  hardware.enableRedistributableFirmware = lib.mkDefault true;

  environment = {
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
      # Default root password is alpinerootroll
      root.password = lib.mkDefault "alpinerootroll";
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
  psilocybin.enable = lib.mkDefault true;

  services = {
    # temporarily disabled because it isn't working in nixos-unstable-small
    # Use kmscon as virtual console instead of gettys
    # kmscon = {
    #   enable = true;
    #   fonts = lib.singleton {
    #     name = "Spleen";
    #     package = pkgs.spleen;
    #   };
    # };
    dbus = {
      enable = true;
      implementation = "broker";
    };
  };

  # Boot faster
  systemd.services.systemd-udev-settle.enable = false;

  system.stateVersion = stateVersion;
  # Include git commit hash on boot label
  system.configurationRevision = lib.mkIf (self ? rev) self.rev;
}
