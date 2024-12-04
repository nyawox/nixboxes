# forgejo@hostname:user/repo.git
# after enabling this module the service may fail to start the first time
# deploy with --auto-rollback=false and reboot
{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.modules.services.forgejo;
  domain = "git.nixlap.top";
in
{
  options = {
    modules.services.forgejo = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
      port = mkOption {
        type = types.int;
        default = 3145;
      };
      sshPort = mkOption {
        type = types.int;
        default = 22;
      };
    };
  };
  config = mkIf cfg.enable {
    services.forgejo = {
      enable = true;
      stateDir = "/var/lib/forgejo";
      database.type = "postgres";
      lfs.enable = true;
      settings = {
        service.DISABLE_REGISTRATION = true;
        default.APP_NAME = "forgejo";
        server = {
          DOMAIN = domain;
          ROOT_URL = "https://${domain}";
          HTTP_PORT = cfg.port;
          START_SSH_SERVER = true;
          SSH_PORT = cfg.sshPort;
        };
        session.COOKIE_SECURE = true;
        security = {
          INSTALL_LOCK = true;
          DISABLE_GIT_HOOKS = false;
        };
        repository = {
          DEFAULT_PRIVATE = "private";
          DEFAULT_BRANCH = "main";
          ENABLE_PUSH_CREATE_USER = true;
        };
        mailer.ENABLED = false;
        actions.ENABLED = false;
      };
    };

    users = {
      groups.forgejo = { };
      users.forgejo = {
        group = "forgejo";
        isSystemUser = true;
      };
    };
    systemd.services.forgejo = {
      serviceConfig = optionalAttrs (cfg.sshPort < 1024) {
        AmbientCapabilities = mkForce "CAP_NET_BIND_SERVICE";
        CapabilityBoundingSet = mkForce "CAP_NET_BIND_SERVICE";
        PrivateUsers = mkForce false;
      };
    };
    environment.persistence."/persist".directories =
      mkIf config.modules.sysconf.impermanence.enable
        (singleton {
          directory = "/var/lib/forgejo";
          user = "forgejo";
          group = "forgejo";
          mode = "750";
        });
  };
}
