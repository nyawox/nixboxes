{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.sysconf.zram;
in {
  options = {
    modules.sysconf.zram = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Enable zram
        '';
      };
    };
  };
  config = mkIf cfg.enable {
    # Replace disk swap with zram
    zramSwap = {
      enable = true;
      memoryPercent = 100;
    };
  };
}
