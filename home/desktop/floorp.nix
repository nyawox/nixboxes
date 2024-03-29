{
  lib,
  pkgs,
  ...
}: let
  catppuccin-tridactyl = {
    "owner" = "lonepie";
    "repo" = "catppuccin-tridactyl";
    "rev" = "a77c65f7ab5946b37361ae935d2192a9a714f960";
    "hash" = "sha256-LjLMq7vUwDdxgpdP9ClRae+gN11IPc+XMsx8/+bwUy4=";
  };
  ugetintegration = pkgs.nur.repos.rycee.firefox-addons.buildFirefoxXpiAddon rec {
    pname = "ugetintegration";
    version = "2.1.3.1";
    addonId = "uget-integration@slgobinath";
    url = "https://addons.mozilla.org/firefox/downloads/file/911315/ugetintegration-${version}.xpi";
    sha256 = "11dfw494dgx4qx63cmlv61rpifr1sxyfyacf6dd4x7ppbp52jpr3";
    meta = with lib; {
      homepage = "https://github.com/ugetdm/uget-integrator";
      description = "integrate uGet Download Manager with web browsers";
      license = licenses.gpl3;
      platforms = platforms.all;
    };
  };
  linkding-injector = pkgs.nur.repos.rycee.firefox-addons.buildFirefoxXpiAddon rec {
    pname = "linkding-injector";
    version = "1.3.4";
    addonId = "{19561335-5a63-4b4e-8182-1eced17f9b47}";
    url = "https://addons.mozilla.org/firefox/downloads/file/4190205/linkding_injector-${version}.xpi";
    sha256 = "0w0frb3pxizdfqypvbmv73a7ifykvnq4486q8pwlijhyyph7kf9y";
    meta = with lib; {
      homepage = "https://github.com/Fivefold/linkding-injector";
      description = "Injects search results from the linkding bookmark service into search pages like google and duckduckgo";
      license = licenses.mit;
      platforms = platforms.all;
    };
  };
  catppuccin = pkgs.nur.repos.rycee.firefox-addons.buildFirefoxXpiAddon {
    pname = "catppuccin";
    version = "2022-08-22";
    addonId = "{0a2d1098-69a9-4e98-a62c-a861766ac24d}";
    url = "https://github.com/catppuccin/firefox/releases/download/old/catppuccin_mocha_pink.xpi";
    sha256 = "00l5aa74k24q5knjfaws5y73d976llj6xp8f1jdxma93jdaqdxih";
    meta = with lib; {
      homepage = "https://github.com/catppuccin/firefox";
      description = "🦊 Soothing pastel theme for Firefox ";
      license = licenses.mit;
      platforms = platforms.all;
    };
  };
in {
  programs.floorp = {
    enable = true;
    package = pkgs.floorp.override {
      nativeMessagingHosts = with pkgs; [
        uget-integrator
        tridactyl-native
      ];
    };
    profiles.default = {
      name = "default";
      isDefault = true;

      bookmarks = [
        # {
        #   name = "wikipedia";
        #   tags = ["wiki"];
        #   keyword = "wiki";
        #   url = "https://en.wikipedia.org/wiki/Special:Search?search=%s&go=Go";
        # }
        # {
        #   name = "kernel.org";
        #   url = "https://www.kernel.org";
        # }
        # {
        #   name = "Nix sites";
        #   toolbar = true;
        #   bookmarks = [
        #     {
        #       name = "homepage";
        #       url = "https://nixos.org/";
        #     }
        #     {
        #       name = "wiki";
        #       tags = ["wiki" "nix"];
        #       url = "https://nixos.wiki/";
        #     }
        #   ];
        # }
      ];

      extensions = with pkgs.nur.repos.rycee.firefox-addons; [
        ublock-origin
        tridactyl
        languagetool
        stylus
        h264ify
        bitwarden
        refined-github
        sponsorblock
        linkding-extension
        unpaywall
        don-t-fuck-with-paste
        consent-o-matic
        ugetintegration
        linkding-injector
        return-youtube-dislikes
        firefox-color
        catppuccin
      ];

      search = {
        # default = "SearXNG";
        default = "Perplexity";
        force = true;
        engines = {
          "Perplexity" = {
            urls = [
              {
                template = "https://www.perplexity.ai/search?focus=internet&copilot=true&q={searchTerms}";
              }
            ];
          };
          "SearXNG" = {
            urls = [
              {
                template = "https://search.nixhome.shop/search?q={searchTerms}";
              }
            ];
            iconUpdateURL = "https://nixos.wiki/favicon.png";
            updateInterval = 24 * 60 * 60 * 1000; # every day
            definedAliases = ["@nw"];
          };
          "Nix Packages" = {
            urls = [
              {
                template = "https://search.nixos.org/packages";
                params = [
                  {
                    name = "type";
                    value = "packages";
                  }
                  {
                    name = "query";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];

            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = ["@np"];
          };

          "NixOS Wiki" = {
            urls = [
              {
                template = "https://nixos.wiki/index.php?search={searchTerms}";
              }
            ];
            iconUpdateURL = "https://nixos.wiki/favicon.png";
            updateInterval = 24 * 60 * 60 * 1000; # every day
            definedAliases = ["@nw"];
          };

          "Google".metaData.alias = "@g";
        };
      };
      settings = {
        "floorp.tabbar.style" = 2;
        "floorp.browser.tabbar.settings" = 2;
        "browser.display.statusbar" = true;
        "floorp.navbar.bottom" = true;
        "floorp.bookmarks.fakestatus.mode" = true;
        # Enable drm
        "media.eme.enabled" = true;

        "browser.search.region" = "US";
        "browser.search.isUS" = true;
        "distribution.searchplugins.defaultLocale" = "en-US";
        "general.useragent.locale" = "en-US";
        "browser.bookmarks.showMobileBookmarks" = true;
        "browser.newtabpage.pinned" = [
          {
            title = "NixOS";
            url = "https://nixos.org";
          }
        ];
        # Fix big fonts in 1080p screen
        "layout.css.devPixelsPerPx" = 0.75;
        # Downloading random PDFs from http website is super annoing with this.
        "dom.block_download_insecure" = false;

        # Always use XDG portals for stuff
        "widget.use-xdg-desktop-portal.file-picker" = 1;

        # Automatically enable extensions installed by home-manager
        "extensions.autoDisableScopes" = 0;

        #Show more ssl cert infos
        "security.identityblock.show_extended_validation" = true;

        "browser.EULA.override" = true;

        #History & Session
        #delete history after one week
        "browser.history_expire_days" = 7;
        #restore pinned tabs
        "browser.sessionstore.restore_pinned_tabs_on_demand" = true;

        #Enable startup page
        "browser.startup.page" = 1;
        "browser.startup.homepage" = "https://homepage.nixhome.shop";
        #speed
        "network.http.max-persistent-connections-per-server" = 30;
        "browser.cache.disk.enable" = false;
      };
    };
  };

  xdg.configFile."tridactyl/tridactylrc".source = ./tridactylrc;
  xdg.configFile."tridactyl/themes/catppuccin.css".source =
    pkgs.fetchFromGitHub catppuccin-tridactyl + "/catppuccin.css";
}
