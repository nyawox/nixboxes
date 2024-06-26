{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.services.caddy;
  expire-header =
    /*
    conf
    */
    ''
      @static {
        file
        path *.ico *.css *.js *.gif *.jpg *.jpeg *.png *.svg *.woff
      }
      header @static Cache-Control max-age=5184000
    '';
  encode =
    /*
    conf
    */
    ''
      encode gzip zstd
    '';
  auth =
    /*
    conf
    */
    ''
      forward_auth nixpro64.nyaa.nixlap.top:9150 {
      	uri /api/verify?rd=https://auth.nixlap.top
      	copy_headers Remote-User Remote-Groups Remote-Name Remote-Email
      }
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
      globalConfig = '''';
      virtualHosts = {
        "homepage.nixlap.top" = {
          useACMEHost = "nixlap.top";
          extraConfig = lib.strings.concatStrings [
            expire-header
            encode
            ''
              reverse_proxy http://tomoyo.nyaa.nixlap.top:8082
            ''
          ];
        };
        "search.nixlap.top" = {
          useACMEHost = "nixlap.top";
          extraConfig = lib.strings.concatStrings [
            expire-header
            encode
            auth
            ''
              reverse_proxy http://vultr.nyaa.nixlap.top:8420
            ''
          ];
        };
        "vault.nixlap.top" = {
          useACMEHost = "nixlap.top";
          extraConfig = lib.strings.concatStrings [
            expire-header
            encode
            ''
              reverse_proxy http://nixpro64.nyaa.nixlap.top:3011
            ''
          ];
        };
        "couch.nixlap.top" = {
          useACMEHost = "nixlap.top";
          extraConfig = lib.strings.concatStrings [
            expire-header
            encode
            ''
              reverse_proxy http://nixpro64.nyaa.nixlap.top:5914
            ''
          ];
        };
        "linkding.nixlap.top" = {
          useACMEHost = "nixlap.top";
          extraConfig = lib.strings.concatStrings [
            expire-header
            encode
            ''
              reverse_proxy http://tomoyo.nyaa.nixlap.top:9090
            ''
          ];
        };
        "auth.nixlap.top" = {
          useACMEHost = "nixlap.top";
          extraConfig = lib.strings.concatStrings [
            expire-header
            encode
            ''
              reverse_proxy http://nixpro64.nyaa.nixlap.top:9150
            ''
          ];
        };
        "netdata.nixlap.top" = {
          useACMEHost = "nixlap.top";
          extraConfig = lib.strings.concatStrings [
            expire-header
            encode
            auth
            ''
              reverse_proxy http://tomoyo.nyaa.nixlap.top:19999
            ''
          ];
        };
        "ntfy.nixlap.top" = {
          useACMEHost = "nixlap.top";
          extraConfig = lib.strings.concatStrings [
            expire-header
            encode
            ''
              reverse_proxy http://nixpro64.nyaa.nixlap.top:2521
            ''
          ];
        };
        "ai.nixlap.top" = {
          useACMEHost = "nixlap.top";
          extraConfig = lib.strings.concatStrings [
            expire-header
            encode
            auth
            ''
              reverse_proxy http://tomoyo.nyaa.nixlap.top:11454
            ''
          ];
        };
        "hass.nixlap.top" = {
          useACMEHost = "nixlap.top";
          extraConfig = lib.strings.concatStrings [
            expire-header
            encode
            ''
              reverse_proxy http://nixpro64.nyaa.nixlap.top:8123
            ''
          ];
        };
      };
    };
  };
}
