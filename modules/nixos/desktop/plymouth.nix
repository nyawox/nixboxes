{
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.modules.desktop.plymouth;
in {
  options = {
    modules.desktop.plymouth = {
      enable = mkOption {
        type = types.bool;
        default = true;
      };
    };
  };
  config = mkIf cfg.enable {
    boot.plymouth.enable = lib.mkDefault true;
  };
}
