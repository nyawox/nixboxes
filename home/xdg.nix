{
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.modules.common.xdg;
in
{
  options = {
    modules.common.xdg = {
      enable = mkOption {
        type = types.bool;
        default = true;
      };
    };
  };
  config = mkIf cfg.enable {
    xdg.userDirs.enable = true;
    xdg.mimeApps.enable = true;
  };
}
