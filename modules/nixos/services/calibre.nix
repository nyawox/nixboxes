{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.services.calibre;
in {
  options = {
    modules.services.calibre = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
      port = mkOption {
        type = types.int;
        default = 8195;
      };
      webPort = mkOption {
        type = types.int;
        default = 8095;
      };
      library = mkOption {
        type = types.str;
        default = "/var/lib/calibre-server";
      };
    };
  };
  config = mkIf cfg.enable {
    services = {
      calibre-server = {
        enable = true;
        port = cfg.port;
        libraries = [cfg.library];
      };
      calibre-web = {
        enable = true;
        listen.port = cfg.webPort;
        options = {
          enableBookConversion = true;
          enableBookUploading = true;
          calibreLibrary = cfg.library;
        };
      };
    };
    environment.persistence."/persist".directories = mkIf config.modules.sysconf.impermanence.enable [
      {
        directory = "/var/lib/calibre-server";
        user = "calibre-server";
        group = "calibre-server";
        mode = "750";
      }
      {
        directory = "/var/lib/calibre-web";
        user = "calibre-web";
        group = "calibre-web";
        mode = "750";
      }
    ];
  };
}
