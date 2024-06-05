{
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.modules.shell.lsd;
in {
  options = {
    modules.shell.lsd = {
      enable = mkOption {
        type = types.bool;
        default = true;
      };
    };
  };
  config = mkIf cfg.enable {
    programs.lsd = {
      enable = true;
      enableAliases = true;
    };
  };
}
