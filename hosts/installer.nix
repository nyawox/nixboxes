{
  lib,
  pkgs,
  hostname,
  platform,
  ...
}: {
  networking.hostName = hostname;

  modules = {
    sysconf = {
      networkd.enable = false;
      networkmanager.enable = true;
      impermanence.enable = false;
      disko.enable = false;
    };
    services.monitoring.enable = false;
  };

  # Building man-cache on qemu is very slow.
  documentation.man.generateCaches = lib.mkIf (platform != "x86_64-linux") false;

  boot = {
    consoleLogLevel = 0;
    initrd.verbose = false;
    initrd.systemd.enable = false;
    kernelPackages = pkgs.linuxPackages;
  };
  # don't suspend to make sure machine will be always accessible through ssh
  # services.xserver.displayManager.gdm.autoSuspend = false;
  # make sure hyprland works in nvidia? idk
  # programs.hyprland.enableNvidiaPatches = true;
  # Allow ssh access
  services.openssh = {
    extraConfig = ''
      AllowUsers root nixos
    '';
    openFirewall = lib.mkForce true;
  };
  users.users."root".openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP9QP7hABDQ+esrZnDhQulFfrhfuT8cPmREYvtPRzjF4 93813719+nyawox@users.noreply.github.com"
  ];
}
