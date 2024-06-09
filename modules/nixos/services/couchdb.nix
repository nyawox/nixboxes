# https://couch.nixlap.top
# https://github.com/vrtmrz/obsidian-livesync/blob/main/docs/setup_own_server.md
# Setting up with URI doesn't work, use minimal setup
# Database name is obsidian
# Username, password, and e2e passphrase are stored somewhere securely
# Enable path obfuscation and select "livesync" as the preset
{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  # couchdb-prestart fails to create local.ini due to permission issues
  # Create local.ini with proper permissions before it starts, including admin secrets if still doesn't exist
  configFile = "/var/lib/couchdb/local.ini";
  initScript = pkgs.writeShellScriptBin "couchdb-init.sh" ''
    mkdir -p /var/lib/couchdb
    touch ${configFile}
    grep -q "admin" ${configFile} || cat "/run/secrets/couchdb-admin" >> ${configFile}
    chown -R couchdb:couchdb /var/lib/couchdb
  '';
  cfg = config.modules.services.couchdb;
in {
  options = {
    modules.services.couchdb = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };
  config = mkIf cfg.enable {
    services = {
      couchdb = {
        enable = true;
        bindAddress = "0.0.0.0";
        port = 5914;
        extraConfig = lib.fileContents ./couchdb-config.ini;
      };
      restic.backups.couchdb = {
        initialize = true;
        paths = ["/var/lib/couchdb"];
        passwordFile = config.sops.secrets.restic-couchdb-pw.path;
        environmentFile = config.sops.secrets.restic-couchdb-env.path;
        repository = "b2:couchdb-nyan";
        timerConfig = {
          # backup every 1d
          OnUnitActiveSec = "1d";
        };
        pruneOpts = [
          "--keep-daily 1"
          "--keep-weekly 1"
          "--keep-yearly 1"
        ];
      };
    };
    sops.secrets = {
      couchdb-admin = {
        sopsFile = ../../../secrets/couchdb-admin.psk;
        format = "binary";
      };
      restic-couchdb-pw = {
        sopsFile = ../../../secrets/restic-couchdb.psk;
        format = "binary";
      };
      restic-couchdb-env = {
        sopsFile = ../../../secrets/restic-couchdb.env;
        format = "dotenv";
      };
    };
    systemd.services.couchdb-init = {
      wantedBy = ["couchdb.service"];
      before = ["couchdb.service"];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${lib.getExe initScript}";
      };
    };
    environment.persistence."/persist".directories = mkIf config.modules.sysconf.impermanence.enable [
      "/var/lib/couchdb"
    ];
  };
}
