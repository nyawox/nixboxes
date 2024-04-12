{
  lib,
  pkgs,
  ...
}: let
  arcwtf = {
    owner = "KiKaraage";
    repo = "ArcWTF";
    rev = "8f36d39233c0d3321e90e0ddb7068d18348485f2";
    hash = "sha256-5ODXoDJF8zYRGm/l4r2QQ6+kwM/nbUv6kl4o/zHXyCk=";
  };
  # blurfox = pkgs.stdenv.mkDerivation {
  #   pname = "blurfox";
  #   version = "1.0.0";

  #   src = pkgs.fetchzip {
  #     stripRoot = false;
  #     url = "https://github.com/safak45xx/Blurfox/releases/download/1.0.0/chrome.zip";
  #     hash = "sha256-+xvjXT2ZV5llaf1fwI53nPd6AIjc/gjzz0QOL8qZRP8=";
  #   };

  #   buildPhase = "";
  #   installPhase = ''
  #     mkdir -p $out
  #     mv chrome/* $out
  #   '';
  # };
  catppuccin-tridactyl = {
    "owner" = "lonepie";
    "repo" = "catppuccin-tridactyl";
    "rev" = "a77c65f7ab5946b37361ae935d2192a9a714f960";
    "hash" = "sha256-LjLMq7vUwDdxgpdP9ClRae+gN11IPc+XMsx8/+bwUy4=";
  };
  smoothfox =
    pkgs.fetchFromGitHub {
      owner = "yokoffing";
      repo = "Betterfox";
      rev = "c36643914571d10b45f863e3916441071b838ae3";
      hash = "sha256-eHocB5vC6Zjz7vsvGOTGazuaUybqigODEIJV9K/h134=";
    }
    + "/Smoothfox.js";
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
        pkgs.nur.repos.rycee.firefox-addons."2fas-two-factor-authentication"
      ];

      search = {
        # default = "SearXNG";
        default = "Google";
        force = true;
        engines = {
          "Perplexity" = {
            urls = [
              {
                template = "https://www.perplexity.ai/search?focus=internet&copilot=true&q={searchTerms}";
              }
            ];
            definedAliases = ["@p"];
          };
          "SearXNG" = {
            urls = [
              {
                template = "https://search.nixhome.shop/search?q={searchTerms}";
              }
            ];
            iconUpdateURL = "https://nixos.wiki/favicon.png";
            updateInterval = 24 * 60 * 60 * 1000; # every day
            definedAliases = ["@sx"];
          };
          "nixpkgs" = {
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

          "nixwiki" = {
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
      extraConfig = builtins.readFile smoothfox;
      userChrome = ''
        /* ArcWTF main files */
        @import url("icons/icons.css");
        /* the tabbar css makes tiny and ugly
        /*@import url("toolbar/tabbar.css");*/
        @import url("toolbar/navbar.css");
        @import url("toolbar/personalbar.css");
        @import url("toolbar/findbar.css");
        @import url("toolbar/urlbar.css");
        @import url("global/colors.css");
        @import url("global/popup.css");
        @import url("global/browser.css");
        @import url("global/tree.css");

        /* Tweaks */
        @import url("global/tweaks.css");
        @import url("tweaks/hide-tabs-bar.css") (-moz-bool-pref: "uc.tweak.hide-tabs-bar");
        @import url("tweaks/cleaner_extensions_menu.css");

        /* global font */
        * {
          font-family: IBM Plex Sans, sans-serif !important;
          font-size: 10pt !important;
        }


        :root #urlbar,
        :root .searchbar-textbox {
          font-size: unset !important;
          min-height: 30px !important;
        }

        :root #identity-box {
          max-height: 28px;
        }

        #main-window[titlepreface*="|| "] {
          --ovrl-wdt: var(--ovrl-max-wdt);

          & :is(#sidebar-box) {
          --uc-sidebar-width: var(--uc-sidebar-hover-width);
            opacity: 100%;
            overflow: visible;
            /* & > * { opacity: 100%; } */
          }

          & .browserContainer::after {
            margin-left: calc(var(--sdbr-real-wdt) * -1);
          }

          & #browser > #appcontent {
            margin-left: var(--sdbr-real-wdt);
          }
          & #appcontent browser {
            margin-left: 0px;
          }
          & #statuspanel { margin-left: 2px }
        }

        /* Replacing Userchrome Toggle icon with a sidebar icon */
        :is(.webextension-browser-action, .eom-addon-button)[data-extensionid="userchrome-toggle@joolee.nl"] .toolbarbutton-icon { list-style-image: url(./icons/userchrome-toggle.svg); }

        /* [NOTICE] Uncomment the code below, from #sidebar-box until right before "collapsing sidebar header", if you want autohide sidebar. */
         * Show sidebar only when the cursor is over it  */
         * The border controlling sidebar width will be removed so you'll need to modify these values to change width */

         /* #sidebar-box{
          --uc-sidebar-width: 4px;
          --uc-sidebar-hover-width: 200px;
          --uc-autohide-sidebar-delay: 100ms; /* Wait 0.1s before hiding sidebar */
          --uc-autohide-transition-duration: 115ms;
          --uc-autohide-transition-type: linear;
          position: relative;
          min-width: var(--uc-sidebar-width) !important;
          width: var(--uc-sidebar-width) !important;
          max-width: var(--uc-sidebar-width) !important;
          z-index:1;
        }

        #sidebar-box[positionend]{ direction: rtl }
        #sidebar-box[positionend] > *{ direction: ltr }

        #sidebar-box[positionend]:-moz-locale-dir(rtl){ direction: ltr }
        #sidebar-box[positionend]:-moz-locale-dir(rtl) > *{ direction: rtl }

        #main-window[sizemode="maximized"] #sidebar-box{ --uc-sidebar-width: 1px; }
        #main-window[sizemode="fullscreen"] #sidebar-box{ --uc-sidebar-width: 1px; }

        #sidebar-splitter{ display: none }

        #sidebar-header{
          overflow: hidden;
          color: var(--chrome-color, inherit) !important;
          padding-inline: 0 !important;
        }

        #sidebar-header::before,
        #sidebar-header::after{
          content: "";
          display: flex;
          padding-left: 8px;
        }

        #sidebar-header,
        #sidebar{
          transition: min-width var(--uc-autohide-transition-duration) var(--uc-autohide-transition-type) var(--uc-autohide-sidebar-delay) !important;
          min-width: var(--uc-sidebar-width) !important;
          will-change: min-width;
        }
        #sidebar-box:hover > #sidebar-header,
        #sidebar-box:hover > #sidebar{
          min-width: var(--uc-sidebar-hover-width) !important;
          transition-delay: 0ms !important;
        }

        .sidebar-panel{
          background-color: var(--newtab-text-primary-color) !important;
          color: var(--newtab-text-primary-color) !important;
        }

        .sidebar-panel #search-box{
          -moz-appearance: none !important;
          background-color: rgba(249,249,250,0.1) !important;
          color: inherit !important;
        }

        /* Move statuspanel to the other side when sidebar is hovered so it doesn't get covered by sidebar */

        #sidebar-box:not([positionend]):hover ~ #appcontent #statuspanel{
          inset-inline: auto 0px !important;
        }
        #sidebar-box:not([positionend]):hover ~ #appcontent #statuspanel-label{
          margin-inline: 0px !important;
          border-left-style: solid !important;
        } */

        /* Collapsing sidebar header */
        #sidebar-header {
          visibility: collapse !important;
         }
      '';
      settings = {
        "floorp.tabbar.style" = 2;
        "floorp.browser.tabbar.settings" = 2;
        # Rounded corner
        "floorp.delete.browser.border" = true;
        "browser.display.statusbar" = false;
        "floorp.navbar.bottom" = true;
        "floorp.bookmarks.fakestatus.mode" = true;
        # Open extension sidebar to the right by default
        "sidebar.position_start" = true;
        # Enable drm
        "media.eme.enabled" = true;
        # unlock frame rate
        # "layout.frame_rate" = 0;
        "nglayout.initialpaint.delay" = 0;
        "nglayout.initialpaint.delay_in_oopif" = 0;
        "content.notify.interval" = 100000;
        "browser.startup.preXulSkeltonUI" = false;
        "gfx.webrender.all" = true;
        "gfx.webrender.precache-shaders" = true;
        "gfx.webrender.compositor" = true;
        "gfx.webrender.compositor.force-enabled" = true;
        "media.hardware-video-decoding.enabled" = true;
        "gfx.canvas.accelerated" = true;
        "gfx.canvas.accelerated.cache-items" = true;
        "gfx.canvas.accelerated.cache-size" = 4096;
        "gfx.content.skia-font-cache-size" = 80;
        "layers.gpu-process.enabled" = true;
        "layers.mlgpu.enabled" = true;
        "media.ffmpeg.vaapi.enabled" = true;
        "image.cache.size" = 10485760;
        "image.mem.decode_bytes_at_a_time" = 131072;
        "image.mem.shared.unmap.min_expiration_msn" = 120000;
        "media.memory_cache_max_size" = 1048576;
        "media.memory_caches_combined_limit_kb" = 2560000;
        "media.cache_readahead_limit" = 9000;
        "media.cache_resume_threshold" = 6000;
        "browser.cache.memory.max_entry_size" = 0;
        "network.buffer.cache.size" = 262144;
        "network.buffer.cache.count" = 128;
        "network.http.max-connections" = 1800;
        "network.http.max-persistent-connections-per-server" = 30;
        "network.ssl_tokens_cache_capacity" = 32768;

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
        "layout.css.backdrop-filter.enabled" = true;
        "layers.acceleration.force-enabled" = true;
        #enable userchrome
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        #tweak theme
        "uc.tweak.floating-tabs" = true;
        "uc.tweak.hide-tabs-bar" = false;
        "uc.tweak.rounded-corners" = true;
        "uc.tweak.context-menu.hide-firefox-account" = true;
        "uc.tweak.disable-drag-space" = true;
        "uc.tweak.popup-search" = true;
        "uc.tweak.longer-sidebar" = true;
        "uc.tweak.force-tab-colour" = true;
        "uc.tweak.hide-sidebar-header" = true;
        "uc.tweak.hide-newtab-logo" = true;
        "uc.tweak.remove-tab-separators" = true;
        "browser.uidensity" = 0;
        "svg.context-properties.content.enabled" = true;
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
      };
    };
  };

  xdg.configFile."tridactyl/tridactylrc".source = ./tridactylrc;
  xdg.configFile."tridactyl/themes/catppuccin.css".source =
    pkgs.fetchFromGitHub catppuccin-tridactyl + "/catppuccin.css";

  home.file = {
    ".floorp/default/chrome/content".source = pkgs.fetchFromGitHub arcwtf + "/content";
    ".floorp/default/chrome/global".source = pkgs.fetchFromGitHub arcwtf + "/global";
    ".floorp/default/chrome/icons".source = pkgs.fetchFromGitHub arcwtf + "/icons";
    ".floorp/default/chrome/toolbar".source = pkgs.fetchFromGitHub arcwtf + "/toolbar";
    ".floorp/default/chrome/tweaks".source = pkgs.fetchFromGitHub arcwtf + "/tweaks";
    ".floorp/default/chrome/userContent.css".source = pkgs.fetchFromGitHub arcwtf + "/userContent.css";
  };
}
