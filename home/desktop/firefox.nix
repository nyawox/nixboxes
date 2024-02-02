{
  lib,
  pkgs,
  inputs,
  ...
}: let
  cascade-repo = {
    "owner" = "andreasgrafen";
    "repo" = "cascade";
    "rev" = "2f70e8619ce5c721fe9c0736b25c5a79938f1215";
    "hash" = "sha256-HOOBQ1cNjsDTFSymB3KjiZ1jw3GL16LF/RQxdn0sxr0=";
  };
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
in {
  programs.firefox = {
    enable = false;
    package = pkgs.wrapFirefox pkgs.firefox-unwrapped {
      nativeMessagingHosts = with pkgs; [
        uget-integrator
        tridactyl-native
      ];
      extraPrefs = ''
        // Show more ssl cert infos
        lockPref("security.identityblock.show_extended_validation",true);

        lockPref("browser.EULA.override",true);
        lockPref("browser.tabs.inTitlebar",0);
        lockPref("browser.tabs.tabmanager.enabled",false);
        lockPref("gfx.webrender.all",true);
        // Allow search shortcuts
        lockPref("keyword.enabled",true);

        lockPref("webgl.disabled",false);
        lockPref("media.ffmpeg.vaapi.enabled",true);
        lockPref("media.ffvpx.enabled",true);
        lockPref("media.rdd-vpx.enabled",false);
        lockPref("media.navigator.mediadatadecoder_vpx_enabled",true);
        // Enable DRM
        lockPref("media.eme.enabled",true);

        // History & Session
        // delete history after one week
        lockPref("browser.history_expire_days",7);
        // restore pinned tabs
        lockPref("browser.sessionstore.restore_pinned_tabs_on_demand",true);

        lockPref("privacy.sanitize.sanitizeOnShutdown", false);
        lockPref("privacy.clearOnShutdown.cache", false);
        lockPref("privacy.clearOnShutdown.history", false);
        lockPref("privacy.clearOnShutdown.sessions", false);

        // remove the screenborders, makes you fingerprintable
        lockPref("privacy.resistFingerprinting.letterboxing",false);
        // Use system colors
        lockPref("browser.display.use_system_colors",true);
        // Enable startup page
        lockPref("browser.startup.page",1);
        lockPref("browser.startup.homepage","https://homepage.nixhome.shop");
        // Enable search suggestions
        lockPref("browser.search.suggest.enabled",true);
        lockPref("browser.search.suggest.searches",true);
        // speed
        lockPref("network.http.max-persistent-connections-per-server", 30);
        lockPref("browser.cache.disk.enable", false);
        // disable pocket and firefox view
        lockPref("extensions.pocket.enabled", false);
        lockPref("browser.tabs.firefox-view",false);
        lockPref("browser.tabs.firefox-view-next",false);
        lockPref("browser.tabs.firefox-view-newIcon",false);
      '';
      extraPolicies = {
        OverrideFirstRunPage = "";
        OverridePostUpdatePage = "";
        DisableFirefoxStudies = true;
        DisablePocket = true;
      };
    };
    profiles.default = {
      name = "default";
      isDefault = true;
      # Hardened
      extraConfig = builtins.readFile "${inputs.hardened-firefox}/user.js";

      bookmarks = [
        {
          name = "wikipedia";
          tags = ["wiki"];
          keyword = "wiki";
          url = "https://en.wikipedia.org/wiki/Special:Search?search=%s&go=Go";
        }
        {
          name = "kernel.org";
          url = "https://www.kernel.org";
        }
        {
          name = "Nix sites";
          toolbar = true;
          bookmarks = [
            {
              name = "homepage";
              url = "https://nixos.org/";
            }
            {
              name = "wiki";
              tags = ["wiki" "nix"];
              url = "https://nixos.wiki/";
            }
          ];
        }
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
      ];

      search = {
        # default = "SearXNG";
        default = "Google";
        force = true;
        engines = {
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

        # Enable userChrome.css
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;

        # Automatically enable extensions installed by home-manager
        "extensions.autoDisableScopes" = 0;
      };
      userChrome = ''
        @import 'includes/cascade-config.css';
        @import 'includes/cascade-mocha.css';

        @import 'includes/cascade-layout.css';
        @import 'includes/cascade-responsive.css';
        @import 'includes/cascade-floating-panel.css';

        @import 'includes/cascade-nav-bar.css';
        @import 'includes/cascade-tabs.css';
      '';
    };
  };
  home.file = {
    ".mozilla/firefox/default/chrome/includes/cascade-config.css".source =
      pkgs.fetchFromGitHub cascade-repo + "/chrome/includes/cascade-config.css";
    ".mozilla/firefox/default/chrome/includes/cascade-mocha.css".source =
      pkgs.fetchFromGitHub cascade-repo + "/integrations/catppuccin/cascade-mocha.css";
    ".mozilla/firefox/default/chrome/includes/cascade-layout.css".source =
      pkgs.fetchFromGitHub cascade-repo + "/chrome/includes/cascade-layout.css";
    ".mozilla/firefox/default/chrome/includes/cascade-responsive.css".source =
      pkgs.fetchFromGitHub cascade-repo + "/chrome/includes/cascade-responsive.css";
    ".mozilla/firefox/default/chrome/includes/cascade-floating-panel.css".source =
      pkgs.fetchFromGitHub cascade-repo + "/chrome/includes/cascade-floating-panel.css";
    ".mozilla/firefox/default/chrome/includes/cascade-nav-bar.css".source =
      pkgs.fetchFromGitHub cascade-repo + "/chrome/includes/cascade-nav-bar.css";
    ".mozilla/firefox/default/chrome/includes/cascade-tabs.css".source =
      pkgs.fetchFromGitHub cascade-repo + "/chrome/includes/cascade-tabs.css";
    # Symlink firefox profile for librewolf
    # ".librewolf/profiles.ini".source = config.lib.file.mkOutOfStoreSymlink "/home/${username}/.mozilla/firefox/profiles.ini";
    # ".librewolf/default".source = config.lib.file.mkOutOfStoreSymlink "/home/${username}/.mozilla/firefox/default";
  };

  xdg.configFile."tridactyl/tridactylrc".source = ./tridactylrc;
  xdg.configFile."tridactyl/themes/catppuccin.css".source =
    pkgs.fetchFromGitHub catppuccin-tridactyl + "/catppuccin.css";
}
