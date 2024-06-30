{
  lib,
  config,
  inputs,
  pkgs,
  ...
}:
with lib; let
  cfg = config.modules.desktop.niri;
in {
  imports = [inputs.niri.nixosModules.niri];
  options = {
    modules.desktop.niri = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };
  config = mkIf cfg.enable {
    modules.desktop.polkit.enable = true;
    programs.niri.enable = true;
    nixpkgs.overlays = [inputs.niri.overlays.niri];
    programs.niri.package = pkgs.niri-unstable;
    environment.variables.NIXOS_OZONE_WL = "1";
    environment.systemPackages = with pkgs; [
      wl-clipboard
      wayland-utils
      libsecret
      gamescope
    ];
  };
}
