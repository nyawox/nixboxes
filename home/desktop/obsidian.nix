{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.modules.desktop.obsidian;
in
{
  options = {
    modules.desktop.obsidian = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [ obsidian ];
  };
}
