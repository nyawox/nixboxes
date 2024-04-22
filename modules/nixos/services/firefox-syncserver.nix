{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.modules.services.firefox-syncserver;
  port = 5003;
in {
  options = {
    modules.services.firefox-syncserver = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };
  config = mkIf cfg.enable {
    services.mysql.package = pkgs.mariadb;
    #TODO Fix this is unreachable
    services.firefox-syncserver = {
      enable = true;
      secrets = config.sops.secrets.firefoxsync.path;
      settings = {inherit port;};
      logLevel = "error";
      singleNode = {
        enable = true;
        hostname = "0.0.0.0";
        url = "http://0.0.0.0:5003";
      };
    };
    sops.secrets.firefoxsync = {
      sopsFile = ../../../secrets/firefoxsync.env;
      format = "dotenv";
    };

    networking.firewall.allowedTCPPorts = [5003];
  };
}
