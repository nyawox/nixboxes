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
    };
    environment.persistence."/persist".directories = [
      "/var/lib/flatpak"
    ];
  };
}
