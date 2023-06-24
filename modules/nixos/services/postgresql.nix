{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.modules.services.postgresql;
in {
  options = {
    modules.services.postgresql = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };
  config = mkIf cfg.enable {
    services.postgresql = {
      enable = true;
      # 15 have permission issues
      package = pkgs.postgresql_14;
      ensureDatabases = ["hass" "vaultwarden"];
      ensureUsers = [
        {
          name = "hass";
          ensurePermissions = {
            "DATABASE hass" = "ALL PRIVILEGES";
          };
        }
      ];
    };
    services.postgresqlBackup = {
      enable = true;
      backupAll = true;
      compression = "zstd";
      compressionLevel = 16;
      location = "/var/backup/postgresql";
    };
    environment.persistence."/persist".directories = mkIf config.modules.sysconf.impermanence.enable [
      "/var/lib/postgresql"
    ];
  };
}
