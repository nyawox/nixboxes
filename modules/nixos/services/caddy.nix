{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.services.caddy;
in {
  options = {
    modules.services.caddy = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };
  config = mkIf cfg.enable {
    services.caddy = {
      enable = true;
      globalConfig = ''
      '';
      virtualHosts."homepage.nixhome.shop" = {
        useACMEHost = "nixhome.shop";
        extraConfig = ''
          reverse_proxy http://tomoyo.nyaa.nixhome.shop:8082
        '';
      };
    };
  };
}
