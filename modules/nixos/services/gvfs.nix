{
  config,
  lib,
  pkgs,
  username,
  ...
}:
with lib;
let
  cfg = config.modules.services.gvfs;
in
{
  options = {
    modules.services.gvfs = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };
  config = mkIf cfg.enable {
    modules.services.avahi.enable = true;
    modules.services.usbmuxd.enable = true;
    services.gvfs = {
      enable = true;
      package = pkgs.gnome.gvfs;
    };
    networking.firewall = {
      allowedTCPPorts = [ 5353 ];
      allowedUDPPorts = [ 5353 ];
    };

    environment = {
      systemPackages = with pkgs; [
        libimobiledevice
        ifuse
        gvfs
      ];
      persistence."/persist".users."${username}".directories =
        mkIf config.modules.sysconf.impermanence.enable
          [
            ".local/share/gvfs-metadata"
          ];
    };
  };
}
