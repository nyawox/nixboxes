{
  lib,
  config,
  inputs,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.modules.desktop.niri;
in
{
  imports = [ inputs.niri.nixosModules.niri ];
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
    programs.niri.enable = true;
    nixpkgs.overlays = [ inputs.niri.overlays.niri ];
    programs.niri.package = pkgs.niri-unstable;
    environment.variables.NIXOS_OZONE_WL = "1";
    environment.systemPackages = with pkgs; [
      wl-clipboard
      wayland-utils
      libsecret
    ];
    services.displayManager.defaultSession = mkIf cfg.default "niri";
    # use seahorse for SSH_ASKPASS
    programs.seahorse.enable = true;
    programs.ssh.enableAskPassword = true;
  };
}
