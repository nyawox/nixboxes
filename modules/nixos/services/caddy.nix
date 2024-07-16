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
  auth-config =
    /*
    conf
    */
    ''
      forward_auth localpost.nyaa.nixlap.top:9150 {
      	uri /api/verify?rd=https://auth.nixlap.top
      	copy_headers Remote-User Remote-Groups Remote-Name Remote-Email
      }
    '';
  block-external-ips =
    /*
    conf
    */
    ''
      import ${config.sops.secrets.caddy-internal-ips.path}
      respond @blocked "Access denied" 403
    '';
  mkProxy = {
    url,
    auth ? false,
    internal ? false,
  }: {
    useACMEHost = "nixlap.top";
    extraConfig = lib.strings.concatStrings [
      expire-header
      encode
      (
        if auth
        then auth-config
        else ""
      )
      (
        if internal
        then block-external-ips
        else ""
      )
      ''
        reverse_proxy ${url}
      ''
    ];
  };
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
    sops.secrets.caddy-internal-ips = {
      sopsFile = ../../../secrets/caddy-internal-ips.conf;
      owner = config.systemd.services.caddy.serviceConfig.User;
      format = "binary";
    };
    services.caddy = {
      enable = true;
      globalConfig = '''';
      virtualHosts = {
        "homepage.nixlap.top" = mkProxy {
          url = "http://localghost.nyaa.nixlap.top:8082";
        };
        "search.nixlap.top" = mkProxy {
          url = "http://localghost.nyaa.nixlap.top:8420";
          auth = true;
        };
        "vault.nixlap.top" = mkProxy {
          url = "http://localpost.nyaa.nixlap.top:3011";
        };
        "s3.nixlap.top" = mkProxy {
          url = "http://localpost.nyaa.nixlap.top:9314";
        };
        "minio.nixlap.top" = mkProxy {
          url = "http://localpost.nyaa.nixlap.top:9315";
          auth = true;
        };
        "linkding.nixlap.top" = mkProxy {
          url = "http://127.0.0.1:9090";
        };
        "auth.nixlap.top" = mkProxy {
          url = "http://localpost.nyaa.nixlap.top:9150";
        };
        "netdata.nixlap.top" = mkProxy {
          url = "http://localpost.nyaa.nixlap.top:19999";
          auth = true;
        };
        "ntfy.nixlap.top" = mkProxy {
          url = "http://localpost.nyaa.nixlap.top:2521";
        };
        "aisearch.nixlap.top" = mkProxy {
          url = "http://localpost.nyaa.nixlap.top:3150";
          auth = true;
        };
        "ai.nixlap.top" = mkProxy {
          url = "http://127.0.0.1:11454";
          auth = true;
        };
        "hs.nixlap.top/admin" = mkProxy {
          url = "http://127.0.0.1:9191";
          auth = true;
        };
        "hass.nixlap.top" = mkProxy {
          url = "http://localpost.nyaa.nixlap.top:8123";
        };
        "adguard1.nixlap.top" = mkProxy {
          url = "http://localpost.nyaa.nixlap.top:3380";
          auth = true;
        };
        "adguard2.nixlap.top" = mkProxy {
          url = "http://localghost.nyaa.nixlap.top:3380";
          auth = true;
        };
      };
    };
  };
}
