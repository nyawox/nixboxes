{
  config,
  lib,
  username,
  pkgs,
  ...
}:
with lib; let
  cfg = config.modules.virtualisation.podman;
in {
  options = {
    modules.virtualisation.podman = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      podman-compose
    ];
    virtualisation = {
      podman = {
        enable = true;
        dockerCompat = true;
        defaultNetwork.settings.dns_enabled = true;
      };
      # Use podman instead of docker
      oci-containers.backend = "podman";
    };

    environment.persistence."/persist" = {
      directories = mkIf config.modules.sysconf.impermanence.enable ["/var/lib/containers"];
      users."${username}".directories = mkIf config.modules.sysconf.impermanence.enable [".local/share/containers"];
    };
  };
}
