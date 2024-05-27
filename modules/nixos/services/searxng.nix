{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.modules.services.searxng;
in
{
  options = {
    modules.services.searxng = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };
  config = mkIf cfg.enable {
    services.searx = {
      enable = true;
      package = pkgs.searxng.overrideAttrs (
        oldAttrs:
        let
          logo = pkgs.fetchurl {
            url = "https://illust8.com/wp-content/uploads/2019/10/cute_purple_cat_5021.png";
            sha256 = "1hdwk9qw72z0jdjf6igx2rwwzc2x3nw804yy2bd3cr3y67rinjg4";
          };
        in
        {
          postInstall = lib.strings.concatStrings [
            oldAttrs.postInstall
            ''
              # Replace logo
              cp ${logo} $out/${pkgs.python3.sitePackages}/searx/static/themes/simple/img/searxng.png
            ''
          ];
        }
      );
      runInUwsgi = true;
      uwsgiConfig = {
        http = ":8420";
      };
      environmentFile = config.sops.secrets.searxng-secret.path;
      settings = {
        general = {
          instance_name = "Search";
          debug = false;
          privacypolicy_url = false;
          donation_url = false;
          contact_url = false;
          enable_metrics = true;
        };
        ui = {
          query_in_title = true;
          results_on_new_tab = false;
          theme_args.simple_style = "dark";
          infinite_scroll = true;
        };
        search = {
          safe_search = 0;
          autocomplete = "google";
        };
        engines = lib.mapAttrsToList (name: value: { inherit name; } // value) {
          "duckduckgo".disabled = true;
          "brave".disabled = true;
          "bing".disabled = false;
          "mojeek".disabled = true;
          "mwmbl".disabled = false;
          "mwmbl".weight = 0.4;
          "qwant".disabled = true;
          "crowdview".disabled = false;
          "crowdview".weight = 0.5;
          "curlie".disabled = true;
          "ddg definitions".disabled = false;
          "ddg definitions".weight = 2;
          "wikibooks".disabled = false;
          "wikidata".disabled = false;
          "wikiquote".disabled = true;
          "wikisource".disabled = true;
          "wikispecies".disabled = false;
          "wikispecies".weight = 0.5;
          "wikiversity".disabled = false;
          "wikiversity".weight = 0.5;
          "wikivoyage".disabled = false;
          "wikivoyage".weight = 0.5;
          "currency".disabled = true;
          "dictzone".disabled = true;
          "lingva".disabled = true;
          "bing images".disabled = false;
          "brave.images".disabled = true;
          "duckduckgo images".disabled = true;
          "google images".disabled = false;
          "qwant images".disabled = true;
          "1x".disabled = true;
          "artic".disabled = false;
          "deviantart".disabled = false;
          "flickr".disabled = true;
          "frinklac".disabled = false;
          "imgur".disabled = false;
          "library of congress".disabled = false;
          "material icons".disabled = true;
          "material icons".weight = 0.2;
          "openverse".disabled = false;
          "pinterest".disabled = true;
          "svgrepo".disabled = false;
          "unsplash".disabled = false;
          "wallhaven".disabled = false;
          "wikicommons.images".disabled = false;
          "yacy images".disabled = true;
          "seekr images (EN)".disabled = true;
          "bing videos".disabled = false;
          "brave.videos".disabled = true;
          "duckduckgo videos".disabled = true;
          "google videos".disabled = false;
          "qwant videos".disabled = false;
          "bilibili".disabled = false;
          "ccc-tv".disabled = true;
          "dailymotion".disabled = true;
          "google play movies".disabled = true;
          "invidious".disabled = true;
          "odysee".disabled = true;
          "peertube".disabled = false;
          "piped".disabled = true;
          "rumble".disabled = false;
          "sepiasearch".disabled = false;
          "vimeo".disabled = true;
          "youtube".disabled = false;
          "mediathekviewweb (DE)".disabled = true;
          "seekr videos (EN)".disabled = true;
          "ina (FR)".disabled = true;
          "brave.news".disabled = true;
          "google news".disabled = true;
          "apple maps".disabled = false;
          "piped.music".disabled = true;
          "radio browser".disabled = true;
          "codeberg".disabled = true;
          "gitlab".disabled = false;
          "internetarchivescholar".disabled = true;
          "pdbe".disabled = true;
        };
        outgoing = {
          # request_timeout = 5.0;       # default timeout in seconds, can be override by engine
          max_request_timeout = 1.6; # the maximum timeout in seconds
          pool_connections = 100; # Maximum number of allowable connections, or null
          pool_maxsize = 10; # Number of allowable keep-alive connections, or null
          enable_http2 = true; # See https://www.python-httpx.org/http2/
        };
        server = {
          port = 8420;
          bind_address = "0.0.0.0";
          secret_key = "@SEARXNG_SECRET@";
          base_url = "https://search.nixlap.top";
          public_instance = false;
          image_proxy = false;
        };
        redis = {
          url = "redis://:searxng@nixpro64.nyaa.nixlap.top:6420";
        };
      };
    };
    sops.secrets.searxng-secret = {
      sopsFile = ../../../secrets/searxng-secret.env;
      format = "dotenv";
    };
  };
}
