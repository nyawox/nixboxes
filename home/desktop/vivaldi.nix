{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.modules.desktop.vivaldi;
in
{
  options = {
    modules.desktop.vivaldi = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };
  config = mkIf cfg.enable {
    programs.chromium = {
      enable = true;
      package = pkgs.vivaldi;
    };
  };
}
