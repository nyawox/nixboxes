{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.modules.services.iphone-fastcharge;
in
{
  options = {
    modules.services.iphone-fastcharge = {
      enable = mkOption {
        type = types.bool;
        default = true;
      };
    };
  };
  config = mkIf cfg.enable {
    services.udev.extraRules =
      # rules
      ''
        SUBSYSTEM=="power_supply", ACTION=="change", RUN+="${getExe pkgs.bash} -c 'echo Fast > %S%p/charge_type || :'"
      '';
  };
}
