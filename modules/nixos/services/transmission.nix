{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.modules.services.transmission;
  # port 9091
in {
  options = {
    modules.services.transmission = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };
  config = mkIf cfg.enable {
    services.transmission = {
      enable = true; #Enable transmission daemon
      # home = "/mnt/transmission/";
      settings = {
        #Override default settings
        dht-enabled = true;
        encryption = 2;
        download-queue-enabled = false;
        download-dir = "/mnt/transmission";
        rpc-bind-address = "0.0.0.0"; #Bind to own IP
        rpc-host-whitelist-enabled = false;
        rpc-whitelist-enabled = false;
      };
    };
    systemd.services.transmission.environment.TRANSMISSION_WEB_HOME =
      pkgs.fetchzip
      {
        url = "https://github.com/6c65726f79/Transmissionic/releases/download/v1.8.0/Transmissionic-webui-v1.8.0.zip";
        sha256 = "9e68krz+xbKpng4WZyiol9oHBNZZ9T45HY4Zc4VTpAg=";
      };

    environment.persistence."/persist".directories = lib.mkIf config.modules.sysconf.impermanence.enable ["/var/lib/transmission"];
  };
}
