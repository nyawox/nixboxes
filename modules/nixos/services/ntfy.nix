# You must add user imperatively
# sudo ntfy user add
{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.services.ntfy-sh;
in {
  options = {
    modules.services.ntfy-sh = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };
  config = mkIf cfg.enable {
    services.ntfy-sh = {
      enable = true;
      settings = {
        listen-http = ":2521";
        base-url = "https://ntfy.nixlap.top";
        auth-default-access = "deny-all";
      };
    };
  };
}
