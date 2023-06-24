{
  lib,
  config,
  pkgs,
  username,
  ...
}:
with lib;
let
  cfg = config.modules.desktop.pipewire;
in
{
  options = {
    modules.desktop.pipewire = {
      enable = mkOption {
        type = types.bool;
        default = true;
      };
    };
  };
  config = mkIf cfg.enable {
    # rtkit is optional but recommended
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      wireplumber = {
        enable = true;
        configPackages = singleton (
          pkgs.writeTextDir "share/wireplumber/wireplumber.conf.d/10-bluez.conf"
            # conf
            ''
              monitor.bluez.properties = {
                bluez5.enable-sbc-xq = true
                bluez5.enable-msbc = true
                bluez5.enable-hw-volume = true
                bluez5.codecs = [ sbc sbc_xq aac ]
              }
            ''
        );
      };
    };
    environment.persistence."/persist".users."${username}" = {
      directories = [ ".local/state/wireplumber" ];
      files = [ ".config/pulse/cookie" ];
    };
  };
}
