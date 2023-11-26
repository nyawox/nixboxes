{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.services.vaultwarden;
  domain = "vault.nixhome.shop";
in {
  options = {
    modules.services.vaultwarden = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
      reverseProxy = mkOption {
        type = types.bool;
        default = false;
      };
      backup = mkOption {
        type = types.bool;
        default = cfg.enable;
      };
    };
  };
  config = {
    services = {
      vaultwarden = mkIf cfg.enable {
        enable = true;
        dbBackend = "postgresql";
        config = {
          rocketAddress = "0.0.0.0";
          rocketPort = 3011;
          signupsAllowed = false;
          databaseUrl = "postgresql://vaultwarden@%2Frun%2Fpostgresql/vaultwarden";
          enableDbWal = "false";
          websocketEnabled = true;
        };
      };
      caddy.virtualHosts.${domain} = mkIf cfg.reverseProxy {
        useACMEHost = "nixhome.shop";
        extraConfig = ''
          reverse_proxy http://nixpro64.nyaa.nixhome.shop:3011
        '';
      };
      restic.backups.vaultwarden-local = mkIf cfg.backup {
        initialize = true;
        paths = ["/var/lib/bitwarden_rs"];
        passwordFile = config.sops.secrets.restic-vaultwarden-pw.path;
        repository = "/var/backup/bitwarden_rs";
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
      restic.backups.vaultwarden = mkIf cfg.backup {
        initialize = true;
        paths = ["/var/lib/bitwarden_rs"];
        passwordFile = config.sops.secrets.restic-vaultwarden-pw.path;
        environmentFile = config.sops.secrets.restic-vaultwarden-env.path;
        repository = "b2:vaultwarden-nyan";
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
    sops.secrets.restic-vaultwarden-pw = mkIf cfg.backup {
      sopsFile = ../../../secrets/restic-vaultwarden.psk;
      format = "binary";
    };
    sops.secrets.restic-vaultwarden-env = mkIf cfg.backup {
      sopsFile = ../../../secrets/restic-vaultwarden.env;
      format = "dotenv";
    };
    environment.persistence."/persist" = mkIf cfg.enable {
      directories = mkIf config.modules.sysconf.impermanence.enable [
        "/var/lib/bitwarden_rs"
      ];
    };
  };
}
