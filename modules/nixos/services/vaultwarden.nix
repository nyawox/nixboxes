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
      borgbackup.jobs.vaultwarden = mkIf cfg.backup {
        paths = "/var/lib/bitwarden_rs";
        encryption.mode = "none";
        repo = "/var/backup/bitwarden_rs";
        compression = "auto,zstd";
        startAt = "daily";
      };
    };
    environment.persistence."/persist" = mkIf cfg.enable {
      directories = mkIf config.modules.sysconf.impermanence.enable [
        "/var/lib/bitwarden_rs"
      ];
    };
  };
}
