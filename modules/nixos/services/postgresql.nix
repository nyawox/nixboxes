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
    services = {
      postgresql = {
        enable = true;
        package = pkgs.postgresql_15;
        ensureDatabases = [
          "hass"
          "vaultwarden"
          "farfalle"
        ];
        ensureUsers = [
          {
            name = "hass";
            ensureDBOwnership = true;
          }
          {
            name = "vaultwarden";
            ensureDBOwnership = true;
          }
          {
            name = "farfalle";
            ensureDBOwnership = true;
          }
        ];
      };
      postgresqlBackup = {
        enable = true;
        backupAll = true;
        compression = "zstd";
        compressionLevel = 16;
        location = "/var/backup/postgresql";
      };
      restic.backups.postgresql = {
        initialize = true;
        paths = ["/var/backup/postgresql"];
        passwordFile = config.sops.secrets.restic-postgresql-pw.path;
        environmentFile = config.sops.secrets.restic-postgresql-env.path;
        repository = "b2:postgresql-nyan";
        timerConfig = {
          # backup every 1d
          OnUnitActiveSec = "1d";
        };
        # keep 7 daily, 5 weekly, and 10 annual backups
        pruneOpts = [
          "--keep-daily 7"
          "--keep-weekly 5"
          "--keep-yearly 10"
        ];
      };
    };
    sops.secrets.restic-postgresql-pw = {
      sopsFile = ../../../secrets/restic-postgresql.psk;
      format = "binary";
    };
    sops.secrets.restic-postgresql-env = {
      sopsFile = ../../../secrets/restic-postgresql.env;
      format = "dotenv";
    };
    environment.persistence."/persist".directories = mkIf config.modules.sysconf.impermanence.enable [
      "/var/lib/postgresql"
      "/var/backup/postgresql"
    ];
  };
}
