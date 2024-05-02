{
  pkgs,
  config,
  username,
  ...
}: let
  exturl = "https://addons.mozilla.org/firefox/downloads/latest";
  arcwtf = pkgs.fetchFromGitHub {
    owner = "kikaraage";
    repo = "arcwtf";
    rev = "bb6f2b7ef7e3d201e23d86bf8636e5d0ea4bd68b";
    hash = "sha256-gyJiIVnyZOYVX6G3m4SSbsb7K9g4zKZWlrHphEIQwsY=";
  };
  catppuccin-tridactyl = pkgs.fetchFromGitHub {
    "owner" = "lonepie";
    "repo" = "catppuccin-tridactyl";
    "rev" = "a77c65f7ab5946b37361ae935d2192a9a714f960";
    "hash" = "sha256-LjLMq7vUwDdxgpdP9ClRae+gN11IPc+XMsx8/+bwUy4=";
  };
in {
  programs.schizofox = {
    enable = true;

    search = {
      defaultSearchEngine = "searx";
      removeEngines = ["Brave" "Bing" "Amazon.com" "eBay" "Twitter" "Wikipedia"];
      searxRandomizer = {
        enable = true;
      };
      # addEngines = [
      #   {
      #     Name = "Etherscan";
      #     Description = "Checking balances";
      #     Alias = "!eth";
      #     Method = "GET";
      #     URLTemplate = "https://etherscan.io/search?f=0&q={searchTerms}";
      #   }
      # ];
    };

    security = {
      sanitizeOnShutdown = false;
      sandbox = false;
      # extraSandboxBinds = [
      #   "/home/${username}/.config/tridactyl"
      # ];
      userAgent = "Mozilla/5.0 (Windows NT 10.0; rv:109.0) Gecko/20100101 Firefox/115.0";
    };

    misc = {
      drm.enable = true;
      disableWebgl = false;
      firefoxSync = true;
      startPageURL = "https://homepage.nixlap.top";
    };

    extensions = {
      simplefox.enable = false;
      darkreader.enable = false;

      extraExtensions = {
        "webextension@metamask.io".install_url = "${exturl}/ether-metamask/latest.xpi";
        "languagetool-webextension@languagetool.org".install_url = "${exturl}/languagetool/latest.xpi";
        "tridactyl.vim@cmcaine.co.uk".install_url = "${exturl}/tridactyl-vim/latest.xpi";
        "admin@2fas.com".install_url = "${exturl}/2fas-two-factor-authentication/latest.xpi";
        "{7a7a4a92-a2a0-41d1-9fd7-1e92480d612d}".install_url = "${exturl}/styl-us/latest.xpi";
        "{9a41dee2-b924-4161-a971-7fb35c053a4a}".install_url = "${exturl}/enhanced-h264ify/latest.xpi";
        "{446900e4-71c2-419f-a6a7-df9c091e268b}".install_url = "${exturl}/bitwarden-password-manager/latest.xpi";
        "{a4c4eda4-fb84-4a84-b4a1-f7c1cbf2a1ad}".install_url = "${exturl}/refined-github-/latest.xpi";
        "sponsorBlocker@ajay.app".install_url = "${exturl}/sponsorblock/latest.xpi";
        "{61a05c39-ad45-4086-946f-32adb0a40a9d}".install_url = "${exturl}/linkding-extension/latest.xpi";
        "{f209234a-76f0-4735-9920-eb62507a54cd}".install_url = "${exturl}/unpaywall/latest.xpi";
        "gdpr@cavi.au.dk".install_url = "${exturl}/consent-o-matic/latest.xpi";
        "{19561335-5a63-4b4e-8182-1eced17f9b47}".install_url = "${exturl}/linkding-injector/latest.xpi";
        "{762f9885-5a13-4abd-9c77-433dcd38b8fd}".install_url = "${exturl}/return-youtube-dislikes/latest.xpi";
        "{3c078156-979c-498b-8990-85f7987dd929}".install_url = "${exturl}/sidebery/latest.xpi";
        "uget-integration@slgobinath".install_url = "${exturl}/ugetintegration/latest.xpi";
        "CanvasBlocker@kkapsner.de".install_url = "${exturl}/canvasblocker/latest.xpi";
        "{76aabc99-c1a8-4c1e-832b-d4f2941d5a7a}".install_url = "${exturl}/catppuccin-mocha-mauve-git/latest.xpi";
        "@contain-amzn".install_url = "${exturl}/contain-amazon/latest.xpi";
        "{a6c4a591-f1b2-4f03-b3ff-767e5bedf4e7}".install_url = "${exturl}/user-agent-string-switcher/latest.xpi";
        "firefox-addon@pronoundb.org".install_url = "${exturl}/pronoundb/latest.xpi";
        "{a218c3db-51ef-4170-804b-eb053fc9a2cd}".install_url = "${exturl}/qr-code-address-bar/latest.xpi";
        # "userchrome-toggle@joolee.nl".install_url = "${exturl}/userchrome-toggle/latest.xpi";
        # "ATBC@EasonWong".install_url = "${exturl}/adaptive-tab-bar-colour/latest.xpi";
      };
    };

    settings = {
      # smoothfox stuff
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

      "layout.css.backdrop-filter.enabled" = true;
      "layers.acceleration.force-enabled" = true;
      #Disable resistFingerprinting and override with much more customizable fingerprintingProtection
      "privacy.resistFingerprinting" = false;
      "privacy.resistFingerprinting.pbmode" = false;
      "privacy.fingerprintingProtection" = true;
      "privacy.fingerprintingProtection.pbmode" = true;
      "privacy.fingerprintingProtection.overrides" = "+AllTargets,-CSSPrefersColorScheme"; # Add ,-JSDateTimeUTC to prevent forcing the time zone to UTC
      "network.http.referer.XOriginPolicy" = 0;
      "privacy.fingerprintingProtection.granularOverrides" = [
        {
          "id" = 1;
          "last_modified" = 1713820945000;
          "overrides" = "-AllTargets";
          "firstPartyDomain" = "*.twitch.tv";
          "thirdPartyDomain" = "*.twitch.tv";
        }
      ];
      "layout.css.font-visibility.private" = 1;
      "layout.css.font-visibility.standard" = 1;
      "layout.css.font-visibility.trackingprotection" = 1;
      #use my own fonts
      "browser.display.use_document_fonts" = true;
      #Enable extensions on mozilla sites
      "extensions.quarantinedDomains.enabled" = false;
      #enable userchrome
      "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
      "svg.context-properties.content.enabled" = true;
      ##### User chrome
      "uc.tweak.floating-tabs" = true;
      "uc.tweak.rounded-corners" = true;
      #####
      # Fix big fonts in 1080p screen
      "layout.css.devPixelsPerPx" = 0.75;
      # Downloading random files from http website is super annoing with this.
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
    };
    theme = {
      font = config.stylix.fonts.serif.name;

      defaultUserChrome.enable = false;
      defaultUserContent.enable = true;

      extraUserChrome = ''
        /* ArcWTF main files */
        @import url("icons/icons.css");
        @import url("toolbar/tabbar.css");
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
        @import url("tweaks/hide-tabs-bar.css");
        @import url("tweaks/extensions.css");
        /* @import url("tweaks/sidebar.css"); */
        @import url("tweaks/popup-search.css");

        /* Replacing Userchrome Toggle icon with Arc sidebar icon */
        :is(.webextension-browser-action, .eom-addon-button)[data-extensionid="userchrome-toggle@joolee.nl"] .toolbarbutton-icon { list-style-image: url(./icons/userchrome-toggle.svg); }

        * {font-family: "Poppins" !important;}

        /* Disable tab bar when sidebery is active. the titlepreface is non width space. */
        #main-window[titlepreface*="​"] #TabsToolbar {
          visibility: collapse !important;
        }

        /* hide sidebar header */
        #sidebar-header {
          visibility: collapse !important;
        }

      '';
    };
  };
  home.packages = with pkgs; [
    uget-integrator
    tridactyl-native
  ];
  home.file = {
    ".mozilla/firefox/schizo.default/chrome/content/".source = arcwtf + "/content";
    ".mozilla/firefox/schizo.default/chrome/global/".source = arcwtf + "/global";
    ".mozilla/firefox/schizo.default/chrome/icons/".source = arcwtf + "/icons";
    ".mozilla/firefox/schizo.default/chrome/toolbar/".source = arcwtf + "/toolbar";
    ".mozilla/firefox/schizo.default/chrome/tweaks/".source = arcwtf + "/tweaks";
    ".mozilla/native-messaging-hosts/com.ugetdm.firefox.json".source = "${pkgs.uget-integrator}/lib/mozilla/native-messaging-hosts/com.ugetdm.firefox.json";
    ".mozilla/native-messaging-hosts/tridactyl.json".source = "${pkgs.tridactyl-native}/lib/mozilla/native-messaging-hosts/tridactyl.json";
  };
  xdg = {
    configFile = {
      "tridactyl/tridactylrc".source = ./tridactylrc;
      "tridactyl/themes/catppuccin.css".source =
        catppuccin-tridactyl + "/catppuccin.css";
    };
    mimeApps = {
      enable = true;
      defaultApplications = {
        "text/html" = "Schizofox.desktop";
        "x-scheme-handler/http" = "Schizofox.desktop";
        "x-scheme-handler/https" = "Schizofox.desktop";
        "x-scheme-handler/about" = "Schizofox.desktop";
        "x-scheme-handler/unknown" = "Schizofox.desktop";
      };
    };
  };
}
