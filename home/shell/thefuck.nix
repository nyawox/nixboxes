{
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.modules.shell.thefuck;
in
{
  options = {
    modules.shell.thefuck = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };
  config = mkIf cfg.enable {
    programs.thefuck = {
      enable = true;
      enableInstantMode = true;
    };
  };
}
