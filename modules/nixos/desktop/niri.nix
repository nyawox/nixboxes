{
  lib,
  config,
  inputs,
  pkgs,
  username,
  ...
}:
with lib;
let
  cfg = config.modules.desktop.niri;
in
{
  imports = [
    inputs.niri.nixosModules.niri
    inputs.niri-session-manager.nixosModules.niri-session-manager
  ];
  options = {
    modules.desktop.niri = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
      default = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };
  config = mkIf cfg.enable {
    modules.sysconf.bluetooth.blueman = true;
    nixpkgs.overlays = [ inputs.niri.overlays.niri ];
    services.displayManager.defaultSession = mkIf cfg.default "niri";
    services.niri-session-manager.enable = true;
    programs = {
      niri = {
        enable = true;
        package = pkgs.niri-unstable;
      };
      # use seahorse for SSH_ASKPASS
      seahorse.enable = true;
      ssh.enableAskPassword = true;
    };
    environment = {
      variables.NIXOS_OZONE_WL = "1";
      systemPackages = with pkgs; [
        wl-clipboard
        wayland-utils
        libsecret
      ];
      persistence."/persist".users."${username}".directories =
        mkIf config.modules.sysconf.impermanence.enable
          [ ".local/share/niri-session-manager" ];
    };
  };
}
