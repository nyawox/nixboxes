{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.sysconf.laptop;
in {
  options = {
    modules.sysconf.laptop = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };
  config = mkIf cfg.enable {
    powerManagement.enable = true;
    services.tlp = {
      # conflicts with cosmic
      # enable = true;
      settings = {
        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

        CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
        CPU_ENERGY_PERF_POLICY_ON_AC = "performance";

        CPU_MIN_PERF_ON_AC = 0;
        CPU_MAX_PERF_ON_AC = 100;
        CPU_MIN_PERF_ON_BAT = 0;
        CPU_MAX_PERF_ON_BAT = 20;
      };
    };
    services.thermald.enable = true;
    programs.light.enable = true;
  };
}
