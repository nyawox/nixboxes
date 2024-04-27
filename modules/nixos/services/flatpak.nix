{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.services.flatpak;
in {
  options = {
    modules.services.flatpak = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };
  config = mkIf cfg.enable {
    services.flatpak = {
      enable = true;
      overrides = {
        global = {
          # Force Wayland by default
          Context.sockets = ["wayland" "!x11" "!fallback-x11"];

          Environment = {
            XCURSOR_PATH = "/run/host/user-share/icons:/run/host/share/icons";
          };
        };
      };
    };
    environment.persistence."/persist".directories = [
      "/var/lib/flatpak"
    ];
  };
}
