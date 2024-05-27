{ lib, config, ... }:
with lib;
let
  cfg = config.modules.desktop.qt;
in
{
  options = {
    modules.desktop.qt = {
      enable = mkOption {
        type = types.bool;
        default = true;
      };
    };
  };
  config = mkIf cfg.enable {
    qt = {
      enable = true;
      platformTheme.name = "gtk";
    };
  };
}
