{
  config,
  lib,
  inputs,
  pkgs,
  username,
  ...
}:
with lib;
let
  cfg = config.modules.virtualisation.arion;
in
{
  imports = [ inputs.arion.nixosModules.arion ];
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
      systemPackages = with pkgs; [ arion ];
      persistence."/persist" = {
        directories = mkIf config.modules.sysconf.impermanence.enable [ "/var/lib/containers" ];
        users."${username}" = {
          directories = mkIf config.modules.sysconf.impermanence.enable [ ".local/share/containers" ];
        };
      };
    };
  };
}
