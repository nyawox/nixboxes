{
  config,
  lib,
  pkgs,
  inputs,
  username,
  ...
}:
with lib; let
  cfg = config.modules.desktop.niri;
in {
  options = {
    modules.desktop.niri = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };
  config = mkIf cfg.enable {
    programs.niri = {
      enable = true;
      package = pkgs.niri-unstable;
    };
    nixpkgs.overlays = [inputs.niri.overlays.niri];

    # Handle keyboard media keys
    sound.mediaKeys.enable = true;
    xdg.portal.enable = true;
    xdg.portal.extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
    ];

    environment.persistence."/persist".users.${username} = {
      directories = [".local/share/nwg-look"];
      files = [".config/xsettingsd/xsettingsd.conf"];
    };
  };
}
