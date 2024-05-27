{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.modules.services.redis;
in
{
  options = {
    modules.services.redis = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.redis-dump ];
    services.redis.servers = {
      searxng = {
        enable = true;
        openFirewall = false;
        port = 6420;
        bind = null;
        databases = 16;
        logLevel = "debug";
        requirePass = "searxng";
        settings = {
          protected-mode = "no";
        };
      };
    };
    environment.persistence."/persist".directories =
      lib.mkIf config.modules.sysconf.impermanence.enable
        [ "/var/lib/redis" ];
  };
}
