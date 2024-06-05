{
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.modules.shell.yazi;
in {
  options = {
    modules.shell.yazi = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };
  config = mkIf cfg.enable {
    programs.yazi = {
      enable = true;
      enableFishIntegration = true;
    };
  };
}
