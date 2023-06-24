{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.modules.sysconf.clevis;
in
{
  options = {
    modules.sysconf.clevis = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ clevis ];
    boot.initrd.network.enable = true;
    boot.initrd.clevis = {
      enable = true;
      useTang = true;
    };
  };
}
