# Do not enable anonymous browsing
{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.modules.services.calibre;
  user = "calibre";
  group = "calibre";
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
        inherit user group;
      };
      calibre-web = {
        enable = true;
        listen = {
          ip = "0.0.0.0";
          port = cfg.webPort;
        };
        options = {
          enableBookConversion = true;
          enableBookUploading = true;
          calibreLibrary = cfg.library;
          reverseProxyAuth.enable = true;
        };
        inherit user group;
      };
    };
    systemd.services.calibre-server.serviceConfig = let
      initLibrary = pkgs.writeShellScript "init-calibre-library" ''
        if [[ -f "/var/lib/calibre-server/metadata.db" ]]; then
          exit 0;
        fi
        lib="/var/lib/calibre-server"
        touch "$lib/book.txt"
        ${getExe' pkgs.calibre "calibredb"} add "$lib/book.txt" --with-library "$lib"
      '';
    in {
      ExecStartPre = mkBefore [initLibrary.outPath];
    };
    systemd.services.calibre-web.after = ["calibre-server.service"];
    users = {
      groups.${user} = {};
      users.${user} = {
        group = "${group}";
        isSystemUser = true;
      };
    };
    environment.persistence."/persist".directories = mkIf config.modules.sysconf.impermanence.enable [
      {
        directory = "/var/lib/calibre-server";
        inherit user group;
        mode = "750";
      }
      {
        directory = "/var/lib/calibre-web";
        inherit user group;
        mode = "750";
      }
    ];
  };
}
