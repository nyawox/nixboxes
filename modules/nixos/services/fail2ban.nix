{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.services.fail2ban;
in {
  options = {
    modules.services.fail2ban = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };
  config = mkIf cfg.enable {
    services.fail2ban = {
      enable = true;
      ignoreIP = ["127.0.0.1/16" "192.168.0.0/16"];
    };
  };
}
