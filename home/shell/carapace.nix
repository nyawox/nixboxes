{
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.modules.shell.carapace;
in {
  options = {
    modules.shell.carapace = {
      enable = mkOption {
        type = types.bool;
        default = true;
      };
    };
  };
  config = mkIf cfg.enable {
    programs.carapace = {
      enable = true;
      enableNushellIntegration = true;
    };
  };
}
