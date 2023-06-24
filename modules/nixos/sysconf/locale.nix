{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.modules.sysconf.locale;
in
{
  options = {
    modules.sysconf.locale = {
      enable = mkOption {
        type = types.bool;
        default = true;
      };
    };
  };
  config = mkIf cfg.enable {
    # Set your time zone.
    time.timeZone = "Asia/Tokyo";

    # Select internationalisation properties.
    i18n.defaultLocale = "en_US.utf8";
  };
}
