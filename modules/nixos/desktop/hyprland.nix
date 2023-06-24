{
  config,
  lib,
  pkgs,
  inputs,
  username,
  ...
}:
with lib; let
  cfg = config.modules.desktop.hyprland;
in {
  options = {
    modules.desktop.hyprland = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };
  config = mkIf cfg.enable {
    programs.hyprland = {
      enable = true;
      package = inputs.hyprland.packages.${pkgs.system}.hyprland;
    };

    services.xserver = {
      # Enable the X11 windowing system.
      enable = true;
      # Configure keymap in X11
      layout = "us";
      xkbVariant = mkIf config.keyboardlayout.dvorak "dvorak";

      displayManager = {
        gdm.enable = mkDefault true;
        autoLogin = {
          enable = true;
          user = "${username}";
        };
        defaultSession = "hyprland";
        sessionPackages = [inputs.hyprland.packages.${pkgs.system}.hyprland];
      };
    };
    services.dbus.enable = true;
    systemd.services."getty@tty1".enable = mkIf config.services.xserver.displayManager.gdm.enable false;
    systemd.services."autovt@tty1".enable = mkIf config.services.xserver.displayManager.gdm.enable false;
    environment.systemPackages = with pkgs; [
      #screen sharing on wayland
      cifs-utils
    ];

    xdg.portal.enable = true;
    xdg.portal.extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
    ];
    # Handle keyboard media keys
    sound.mediaKeys.enable = true;

    environment.persistence."/persist".users.${username} = {
      directories = [".local/share/nwg-look"];
      files = [".config/xsettingsd/xsettingsd.conf"];
    };
  };
}
