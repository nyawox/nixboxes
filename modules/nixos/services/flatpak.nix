{
  config,
  lib,
  inputs,
  username,
  ...
}:
with lib; let
  cfg = config.modules.services.flatpak;
in {
  imports = [inputs.nix-flatpak.nixosModules.nix-flatpak];
  options = {
    modules.services.flatpak = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
      fonts = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };
  config = {
    services.flatpak = mkIf cfg.enable {
      enable = true;
      overrides = {
        global = {
          # Force Wayland by default
          Context.sockets = [
            "wayland"
            "!x11"
            "!fallback-x11"
          ];

          Environment = {
            XCURSOR_PATH = "/run/host/user-share/icons:/run/host/share/icons";
          };
        };
      };
    };
    # symlink fonts to user directory
    systemd.tmpfiles.rules = mkIf cfg.fonts [
      "L+ /home/${username}/.local/share/fonts - - - - /run/current-system/sw/share/X11/fonts"
    ];
    environment.persistence."/persist".directories = mkIf (config.modules.sysconf.impermanence.enable && cfg.enable) [
      "/var/lib/flatpak"
    ];
  };
}
