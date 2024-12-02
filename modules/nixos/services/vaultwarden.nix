{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.modules.services.vaultwarden;
in
{
  options = {
    modules.services.vaultwarden = {
      enable = mkOption {
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
          # signups_allowed = true;
          signups_allowed = false;
          databaseUrl = "postgresql://vaultwarden@%2Frun%2Fpostgresql/vaultwarden";
          enableDbWal = "false";
          websocketEnabled = true;
          ip_header = "X-Real-IP";
        };
      };
      restic.backups.vaultwarden = mkIf cfg.backup {
        initialize = true;
        paths = [ "/var/lib/bitwarden_rs" ];
        passwordFile = config.sops.secrets.restic-vaultwarden-pw.path;
        environmentFile = config.sops.secrets.restic-vaultwarden-env.path;
        repository = "b2:vaultwarden-nyaa";
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
      directories = mkIf config.modules.sysconf.impermanence.enable [ "/var/lib/bitwarden_rs" ];
    };
    modules.services.fail2ban.enable = mkForce true;
    services.fail2ban.jails = {
      vaultwarden.settings = {
        enabled = true;
        filter = "vaultwarden";
        port = 3011;
        maxretry = 5;
      };
      vaultwarden-admin.settings = {
        enabled = true;
        port = 3011;
        filter = "vaultwarden-admin";
        maxretry = 3;
        bantime = 14400;
        findtime = 14400;
      };
    };

    environment.etc = {
      "fail2ban/filter.d/vaultwarden.conf".text = ''
        [INCLUDES]
        before = common.conf

        [Definition]
        failregex = ^.*Username or password is incorrect\. Try again\. IP: <ADDR>\. Username:.*$
        ignoreregex =
        journalmatch = _SYSTEMD_UNIT=vaultwarden.service
      '';
      "fail2ban/filter.d/vaultwarden-admin.conf".text = ''
        [INCLUDES]
        before = common.conf

        [Definition]
        failregex = ^.*Invalid admin token\. IP: <ADDR>.*$
        ignoreregex =
        journalmatch = _SYSTEMD_UNIT=vaultwarden.service
      '';
    };
  };
}
