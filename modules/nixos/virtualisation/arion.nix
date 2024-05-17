{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.modules.virtualisation.arion;
in {
  options = {
    modules.virtualisation.arion = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };
  config = mkIf cfg.enable {
    virtualisation.arion = {
      backend = "podman-socket";
    };
    environment = {
      systemPackages = with pkgs; [
        arion
      ];
      persistence."/persist" = {
        directories = mkIf config.modules.sysconf.impermanence.enable [
          "/var/lib/podman"
        ];
      };
    };
  };
}
