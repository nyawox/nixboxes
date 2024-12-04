# You must add user to /var/lib/authelia-main/users_database.yml manually
# sudo hx /var/lib/authelia-main/notification.txt to check 2fa email
{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.modules.services.authelia;
in
{
  options = {
    modules.services.authelia = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };
  config = mkIf cfg.enable {
    sops.secrets = {
      authelia-jwt = {
        sopsFile = ../../../secrets/authelia-jwt.psk;
        owner = config.systemd.services.authelia-main.serviceConfig.User;
        format = "binary";
      };
      authelia-storage = {
        sopsFile = ../../../secrets/authelia-storage.psk;
        owner = config.systemd.services.authelia-main.serviceConfig.User;
        format = "binary";
      };
      authelia-session = {
        sopsFile = ../../../secrets/authelia-session.psk;
        owner = config.systemd.services.authelia-main.serviceConfig.User;
        format = "binary";
      };
    };
    services.authelia.instances.main = {
      enable = true;
      secrets = {
        jwtSecretFile = config.sops.secrets.authelia-jwt.path;
        storageEncryptionKeyFile = config.sops.secrets.authelia-storage.path;
        sessionSecretFile = config.sops.secrets.authelia-session.path;
      };
      settings = {
        theme = "auto";

        server.address = "0.0.0.0:9150";

        log = {
          level = "debug";
          format = "text";
        };

        authentication_backend = {
          file = {
            path = "/var/lib/authelia-main/users_database.yml";
          };
        };

        access_control = {
          default_policy = "deny";
          rules = [
            {
              domain = [
                "netdata.nixlap.top"
                "search.nixlap.top"
                "aisearch.nixlap.top"
                "minio.nixlap.top"
                "adguard.nixlap.top"
                "adguard-2.nixlap.top"
                "hs.nixlap.top/admin"
                "git.nixlap.top"
              ];
              policy = "two_factor";
              subject = "group:admins";
            }
            {
              domain = [
                "ai.nixlap.top"
              ];
              policy = "two_factor";
              subject = "group:users";
            }
            {
              domain = [ "*.nixlap.top" ];
              policy = "bypass";
            }
          ];
        };

        session = {
          name = "authelia_session";
          expiration = "12h";
          inactivity = "45m";
          remember_me_duration = "1M";
          domain = "nixlap.top";
          redis.host = "/run/redis-authelia-main/redis.sock";
        };

        regulation = {
          max_retries = 3;
          find_time = "5m";
          ban_time = "15m";
        };

        storage = {
          local = {
            path = "/var/lib/authelia-main/db.sqlite3";
          };
        };

        notifier = {
          disable_startup_check = false;
          filesystem = {
            filename = "/var/lib/authelia-main/notification.txt";
          };
        };
      };
    };
    modules.services.redis.enable = mkForce true;
    services.redis.servers.authelia-main = {
      enable = true;
      user = "authelia-main";
      port = 0;
      openFirewall = false;
      unixSocket = "/run/redis-authelia-main/redis.sock";
      unixSocketPerm = 600;
    };
    environment.persistence."/persist".directories = mkIf config.modules.sysconf.impermanence.enable [
      "/var/lib/authelia-main"
    ];
  };
}
