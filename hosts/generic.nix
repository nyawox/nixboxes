{
  config,
  pkgs,
  lib,
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

    kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
    kernelParams = [
      "libahci.ignore_sss=1"
    ];

    initrd.systemd.enable = lib.mkDefault true;

    consoleLogLevel = lib.mkDefault 7;
  };

  hardware.enableRedistributableFirmware = lib.mkDefault true;

  environment = {
    variables.EDITOR = "nvim";
    systemPackages = with pkgs; [
      neovim
      git
      wget
      fastfetch
      pfetch
      # required for direnv
      gnugrep
      # backup
      borgbackup
    ];
  };
  programs = {
    command-not-found.dbPath =
      inputs.programsdb.packages.${pkgs.system}.programs-sqlite;

    fish.enable = true;
    # Otherwise home-manager will fail https://github.com/nix-community/home-manager/issues/3113
    dconf.enable = true;

    # GTK2 fallback to ncurses when gui isn't available
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
      pinentryFlavor = "gtk2";
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
        ];
      };
      # Default root password is alpinerootroll
      root.password = lib.mkDefault "alpinerootroll";
    };
    groups.wheel = {members = ["${username}" "root"];};
    mutableUsers = false;

    defaultUserShell = pkgs.fish;
  };

  services = {
    telegraf.enable =
      if config.modules.services.monitoring.telegraf.enable
      then lib.mkForce true
      else lib.mkForce false;
    # Use kmscon as virtual console instead of gettys
    kmscon = {
      enable = true;
      fonts = [
        {
          name = "BlexMono Nerd Font";
          package = pkgs.nerdfonts.override {fonts = ["IBMPlexMono"];};
        }
      ];
    };
  };

  # Boot faster
  systemd.services.systemd-udev-settle.enable = false;

  system.stateVersion = stateVersion;
}
