{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.modules.services.tor;
in
{
  options = {
    modules.services.tor = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };
  config = mkIf cfg.enable {
    services.tor = {
      enable = true;
      client.enable = true;
      torsocks.enable = true;
      settings = {
        ControlPort = singleton {
          port = 9051;
        };
        CookieAuthentication = true;
        DataDirectoryGroupReadable = true;
        CookieAuthFileGroupReadable = true;
      };
    };
  };
}
