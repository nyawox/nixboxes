{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.modules.sysconf.networkmanager;
in
{
  options = {
    modules.sysconf.networkmanager = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Enable networkmanager
        '';
      };
    };
  };
  config = mkIf cfg.enable {
    networking = {
      networkmanager = {
        enable = true;
        wifi = {
          powersave = false;
          backend = "iwd";
        };
      };
      wireless.enable = false;
    };
    # Don't wait for network startup
    # https://old.reddit.com/r/NixOS/comments/vdz86j/how_to_remove_boot_dependency_on_network_for_a
    systemd.targets.network-online.wantedBy = mkForce [ ]; # Normally ["multi-user.target"]
    systemd.services.NetworkManager-wait-online.wantedBy = mkForce [ ]; # Normally ["network-online.target"]
    environment.persistence."/persist".directories = mkIf config.modules.sysconf.impermanence.enable [
      "/etc/NetworkManager/system-connections"
    ];
  };
}
