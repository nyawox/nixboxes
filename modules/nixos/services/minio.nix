{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.services.minio;
in {
  options = {
    modules.services.minio = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };
  config = mkIf cfg.enable {
    services = {
      minio = {
        enable = true;
        browser = true;
        listenAddress = "0.0.0.0:9314";
        consoleAddress = "0.0.0.0:9315"; # web UI
        rootCredentialsFile = config.sops.secrets.minio-root.path;
      };
    };
    systemd.services.minio = {
      environment = {
        MINIO_SERVER_URL = "https://s3.nixlap.top";
        MINIO_BROWSER_REDIRECT_URL = "https://minio.nixlap.top";
      };
    };
    sops.secrets = {
      minio-root = {
        sopsFile = ../../../secrets/minio-root.env;
        format = "dotenv";
      };
    };
    environment.persistence."/persist".directories = mkIf config.modules.sysconf.impermanence.enable (singleton {
      directory = "/var/lib/minio";
      user = "minio";
      group = "minio";
      mode = "750";
    });
  };
}
