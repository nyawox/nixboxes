{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.services.udisks2;
in {
  options = {
    modules.services.udisks2 = {
      enable = mkOption {
        type = types.bool;
        default = true;
      };
    };
  };
  config = mkIf cfg.enable {
    services.udisks2 = {
      enable = true;
      settings = {
        "mount_options.conf" = {
          defaults = {
            # no need to default to lower compression levels unless it's a fast SSD
            btrfs_defaults = [
              "noatime"
              "compress-force=zstd:3"
            ];
          };
        };
      };
    };
  };
}
