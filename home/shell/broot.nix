{ lib, config, ... }:
with lib;
let
  cfg = config.modules.shell.broot;
in
{
  options = {
    modules.shell.broot = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };
  config = mkIf cfg.enable {
    programs.broot = {
      enable = true;
      settings = {
        modal = true;
        imports = [
          {
            luma = [
              "dark"
              "unknown"
            ];
            file = "skins/catppuccin-mocha.hjson";
          }
        ];
      };
    };
  };
}
