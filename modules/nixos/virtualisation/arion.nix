{
  config,
  lib,
  inputs,
  pkgs,
  username,
  ...
}:
with lib; let
  cfg = config.modules.virtualisation.arion;
in {
  imports = [inputs.arion.nixosModules.arion];
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
      systemPackages = with pkgs; [arion];
      # prevent specfiying two times
      persistence."/persist" = mkIf (!config.modules.virtualisation.podman.enable) {
        directories = mkIf config.modules.sysconf.impermanence.enable ["/var/lib/containers"];
        users."${username}" = {
          directories = mkIf config.modules.sysconf.impermanence.enable [".local/share/containers"];
        };
      };
    };
  };
}
