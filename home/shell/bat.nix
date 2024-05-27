{ lib, config, ... }:
with lib;
let
  cfg = config.modules.shell.bat;
in
{
  options = {
    modules.shell.bat = {
      enable = mkOption {
        type = types.bool;
        default = true;
      };
    };
  };
  config = mkIf cfg.enable {
    programs.bat = {
      enable = true;
      config = {
        pager = "less -FR";
      };
    };
    programs.fish.shellAliases = mkIf config.modules.shell.fish.enable { cat = "bat"; };
  };
}
