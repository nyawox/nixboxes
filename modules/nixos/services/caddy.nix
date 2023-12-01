{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.services.caddy;
  expire-header = ''
    @static {
      file
      path *.ico *.css *.js *.gif *.jpg *.jpeg *.png *.svg *.woff
    }
    header @static Cache-Control max-age=5184000
  '';
  encode = ''
    encode gzip zstd
  '';
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
        extraConfig = lib.strings.concatStrings [
          expire-header
          encode
          ''
            reverse_proxy http://tomoyo.nyaa.nixhome.shop:8082
          ''
        ];
      };
      virtualHosts."search.nixhome.shop" = {
        useACMEHost = "nixhome.shop";
        extraConfig = lib.strings.concatStrings [
          expire-header
          encode
          ''
            reverse_proxy http://tomoyo.nyaa.nixhome.shop:8420
          ''
        ];
      };
    };
  };
}
