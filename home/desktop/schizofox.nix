{
  lib,
  config,
  pkgs,
  inputs,
  username,
  ...
}:
with lib; let
  cfg = config.modules.desktop.schizofox;
  exturl = "https://addons.mozilla.org/firefox/downloads/latest";
in {
  options = {
    modules.desktop.schizofox = {
      enable = mkOption {
        type = types.bool;
        default = true;
      };
    };
  };
  config = mkIf cfg.enable {
    programs.schizofox = {
      enable = true;
      package = pkgs.firefox-unwrapped;

      search = {
        defaultSearchEngine = "searx";
        removeEngines = [
          "Brave"
          "Bing"
          "Amazon.com"
          "eBay"
          "Twitter"
          "Wikipedia (en)"
          "Google"
          "DuckDuckGo"
          "LibRedirect"
        ];
        addEngines = [
          {
            Name = "searx";
            Description = "selfhosted searxng";
            Alias = "sx";
            Method = "GET";
            URLTemplate = "https://search.nixlap.top/search?q={searchTerms}";
          }
          {
            Name = "pp";
            Description = "Perplexity";
            Alias = "pp";
            Method = "GET";
            URLTemplate = "https://www.perplexity.ai/search?q={searchTerms}";
          }
          {
            Name = "fr";
            Description = "Farfalle";
            Alias = "fr";
            Method = "GET";
            URLTemplate = "https://aisearch.nixlap.top/?q={searchTerms}";
          }
        ];
      };

      security = {
        sanitizeOnShutdown = false;
        sandbox = true;
        extraSandboxBinds = [
          "/home/${username}/.config/tridactyl"
          "/home/${username}/.local/share/fonts" # home-manager fonts
          "/etc/profiles/per-user/${username}/share/icons" # home-manager cursor and icon themes
          "/nix/store"
        ];
        userAgent = "Mozilla/5.0 (Windows NT 10.0; rv:109.0) Gecko/20100101 Firefox/115.0";
      };

      misc = {
        drm.enable = true;
        disableWebgl = false;
        firefoxSync = true;
        startPageURL = "https://homepage.nixlap.top";
      };

      extensions = {
        enableDefaultExtensions = true;
        enableExtraExtensions = true;
        simplefox.enable = false;
        darkreader.enable = true;

        extraExtensions = {
          "webextension@metamask.io".install_url = "${exturl}/ether-metamask/latest.xpi";
          "languagetool-webextension@languagetool.org".install_url = "${exturl}/languagetool/latest.xpi";
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
          "searxng-favicons@micahmo.com".install_url = "${exturl}/searxng-favicons/latest.xpi";
          "{93f81583-1fd4-45cc-bff4-abba952167bb}".install_url = "${exturl}/jiffy-reader/latest.xpi";
          "userchrome-toggle-extended@n2ezr.ru".install_url = "${exturl}/userchrome-toggle-extended/latest.xpi";
          "tridactyl.vim@cmcaine.co.uk".install_url = "${exturl}/tridactyl-vim/latest.xpi";
          "shinigamieyes@shinigamieyes".install_url = "${exturl}/shinigami-eyes/latest.xpi";
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
          {
            "id" = 1;
            "last_modified" = 1713820945000;
            "overrides" = "-AllTargets";
            "firstPartyDomain" = "*.netflix.com";
            "thirdPartyDomain" = "*.netflix.com";
          }
        ];
        "layout.css.font-visibility.private" = 1;
        "layout.css.font-visibility.standard" = 1;
        "layout.css.font-visibility.trackingprotection" = 1;
        #Disable autofocus on input fields
        "browser.autofocus" = false;
        #use my own fonts
        "browser.display.use_document_fonts" = true;
        #Enable extensions on mozilla sites
        "extensions.quarantinedDomains.enabled" = false;
        ##### User chrome
        # userchrome.css usercontent.css activate
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;

        # Fill SVG Color
        "svg.context-properties.content.enabled" = true;

        # CSS's `:has()` selector
        "layout.css.has-selector.enabled" = true;

        # Integrated calculator at urlbar
        "browser.urlbar.suggest.calculator" = true;

        # Integrated unit convertor at urlbar
        "browser.urlbar.unitConversion.enabled" = true;

        # Trim  URL
        "browser.urlbar.trimHttps" = true;
        "browser.urlbar.trimURLs" = true;

        # GTK rounded corners
        "widget.gtk.rounded-bottom-corners.enabled" = true;
        # force apple emoji
        "font.name-list.emoji" = "Apple Color Emoji";
        #####
        #Smoother scroll
        "general.smoothScroll.msdPhysics.enabled" = true;
        "general.smoothScroll.msdPhysics.continuousMotionMaxDeltaMS" = 250;
        "general.smoothScroll.msdPhysics.motionBeginSpringConstant" = 450;
        "general.smoothScroll.msdPhysics.regularSpringConstant" = 450;
        "general.smoothScroll.msdPhysics.slowdownMinDeltaMS" = 50;
        "general.smoothScroll.msdPhysics.slowdownMinDeltaRatio" = 0.4;
        "general.smoothScroll.msdPhysics.slowdownSpringConstant" = 5000;
        "general.smoothScroll.currentVelocityWeighting" = 0;
        "general.smoothScroll.mouseWheel.durationMaxMS" = 250;
        "general.smoothScroll.stopDecelerationWeighting" = 0.82;
        "mousewheel.min_line_scroll_amount" = 30;
        "toolkit.scrollbox.verticalScrollDistance" = 5;
        "toolkit.scrollbox.horizontalScrollDistance" = 4;
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
        defaultUserContent.enable = false;

        extraUserChrome =
          /*
          css
          */
          ''
            /* base */
            @import url("ShyFox/shy-variables.css");
            @import url("ShyFox/shy-global.css");

            /* main elements */
            @import url("ShyFox/shy-sidebar.css");
            @import url("ShyFox/shy-toolbar.css");
            @import url("ShyFox/shy-navbar.css");
            @import url("ShyFox/shy-findbar.css");
            @import url("ShyFox/shy-controls.css");

            /* addons */
            @import url("ShyFox/shy-compact.css");
            @import url("ShyFox/shy-icons.css");
            @import url("ShyFox/shy-floating-search.css");

            * {font-family: "Poppins" !important;}
          '';
        extraUserContent =
          /*
          css
          */
          ''
            /* imports */
            @import url("ShyFox/content/shy-new-tab.css");
            @import url("ShyFox/content/shy-about.css");
            @import url("ShyFox/content/shy-global-content.css");
            @import url("ShyFox/shy-variables.css");
          '';
      };
    };
    home.packages = with pkgs; [
      uget-integrator
      # tridactyl-native
    ];
    home.file = {
      ".mozilla/firefox/schizo.default/chrome/ShyFox/".source = inputs.shyfox.outPath + "/chrome/ShyFox";
      ".mozilla/firefox/schizo.default/chrome/icons/".source = inputs.shyfox.outPath + "/chrome/icons";
      ".mozilla/native-messaging-hosts/com.ugetdm.firefox.json".source = "${pkgs.uget-integrator}/lib/mozilla/native-messaging-hosts/com.ugetdm.firefox.json";
      ".mozilla/native-messaging-hosts/tridactyl.json".source = "${pkgs.tridactyl-native}/lib/mozilla/native-messaging-hosts/tridactyl.json";
    };
    xdg = {
      configFile = {
        "tridactyl/tridactylrc".source = ./tridactylrc;
        "tridactyl/themes/catppuccin.css".source = inputs.catppuccin-tridactyl.outPath + "/catppuccin.css";
      };
      mimeApps.defaultApplications = {
        "text/html" = "Schizofox.desktop";
        "x-scheme-handler/http" = "Schizofox.desktop";
        "x-scheme-handler/https" = "Schizofox.desktop";
        "x-scheme-handler/about" = "Schizofox.desktop";
        "x-scheme-handler/unknown" = "Schizofox.desktop";
      };
    };
  };
}
