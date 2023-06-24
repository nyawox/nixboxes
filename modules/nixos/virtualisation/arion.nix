{
  config,
  lib,
  inputs,
  pkgs,
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
    modules.virtualisation.podman.enable = mkForce true;
    virtualisation.arion = {
      backend = "podman-socket";
    };
    environment.systemPackages = with pkgs; [
      arion
      docker-client
    ];
  };
}
