{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.modules.sysconf.maxmem;
in
{
  options = {
    modules.sysconf.maxmem = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          increase the maximum number of memory map areas a process can have
          required for memory intensive applications
        '';
      };
    };
  };
  config = mkIf cfg.enable {
    boot.kernel.sysctl."vm.max_map_count" = mkForce 2147483642; # set to max int - 5.
  };
}
