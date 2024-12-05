{
  lib,
  config,
  pkgs,
  inputs,
  username,
  ...
}:
with lib;
let
  cfg = config.modules.desktop.schizofox;
  exturl = "https://addons.mozilla.org/firefox/downloads/latest";
in
{
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

      # Search engine policies requires ESR
      search = {
        defaultSearchEngine = "LibRedirect";
        removeEngines = [
          "Brave"
          "Bing"
          "Amazon.com"
          "eBay"
          "Twitter"
          "Wikipedia (en)"
          "Google"
          "DuckDuckGo"
        ];
        addEngines = [
          {
            Name = "sx";
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
        ];
      };

      security = {
        sanitizeOnShutdown.enable = false;
        sandbox = true;
        extraSandboxBinds = [
          "/home/${username}/.config/tridactyl"
          "/home/${username}/.local/share/fonts"
          "/home/${username}/.config/fontconfig"
          "/etc/fonts"
          "/etc/profiles/per-user/${username}/share/icons" # home-manager cursor and icon themes
          # xdg-open
          "/etc/profiles/per-user/${username}/share/applications"
          "/run/current-system/sw/share/applications"
          "/nix/store"
        ];
      };

      misc = {
        drm.enable = true;
        disableWebgl = false;
        firefoxSync = true;
        translate.enable = true;
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
          "{9a41dee2-b924-4161-a971-7fb35c053a4a}".install_url = "${exturl}/enhanced-h264ify/latest.xpi";
          "{446900e4-71c2-419f-a6a7-df9c091e268b}".install_url = "${exturl}/bitwarden-password-manager/latest.xpi";
          "{a4c4eda4-fb84-4a84-b4a1-f7c1cbf2a1ad}".install_url = "${exturl}/refined-github-/latest.xpi";
          "sponsorBlocker@ajay.app".install_url = "${exturl}/sponsorblock/latest.xpi";
          "{f209234a-76f0-4735-9920-eb62507a54cd}".install_url = "${exturl}/unpaywall/latest.xpi";
          "gdpr@cavi.au.dk".install_url = "${exturl}/consent-o-matic/latest.xpi";
          "{762f9885-5a13-4abd-9c77-433dcd38b8fd}".install_url = "${exturl}/return-youtube-dislikes/latest.xpi";
          "CanvasBlocker@kkapsner.de".install_url = "${exturl}/canvasblocker/latest.xpi";
          "@contain-amzn".install_url = "${exturl}/contain-amazon/latest.xpi";
          "{a6c4a591-f1b2-4f03-b3ff-767e5bedf4e7}".install_url = "${exturl}/user-agent-string-switcher/latest.xpi";
          "firefox-addon@pronoundb.org".install_url = "${exturl}/pronoundb/latest.xpi";
          "{a218c3db-51ef-4170-804b-eb053fc9a2cd}".install_url = "${exturl}/qr-code-address-bar/latest.xpi";
          "{93f81583-1fd4-45cc-bff4-abba952167bb}".install_url = "${exturl}/jiffy-reader/latest.xpi";
          "tridactyl.vim@cmcaine.co.uk".install_url = "${exturl}/tridactyl-vim/latest.xpi";
          "shinigamieyes@shinigamieyes".install_url = "${exturl}/shinigami-eyes/latest.xpi";
          "7esoorv3@alefvanoon.anonaddy.me".install_url = "${exturl}/libredirect/latest.xpi";
          "{5f2806a5-f66d-40c6-8fb2-6018753b5626}".install_url = "${exturl}/icloud-hide-my-email/latest.xpi";
          "clipper@obsidian.md".install_url = "${exturl}/web-clipper-obsidian/latest.xpi";
        };
      };

      settings = {
        #Disable autofocus on input fields
        "browser.autofocus" = false;
        #use my own fonts
        "browser.display.use_document_fonts" = true;
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
        # Downloading random files from http website is super annoying with this.
        "dom.block_download_insecure" = false;

        # Always use XDG portals for stuff
        "widget.use-xdg-desktop-portal.file-picker" = 1;

        # css
        "ultima.tabs.vertical" = true;
        "ultima.tabs.size.l" = true;
        "ultima.tabs.autohide" = true;
        "ultima.tabs.closetabsbutton" = true;
        "ultima.sidebar.autohide" = true;
        "ultima.sidebar.longer" = true;
        "ultima.theme.extensions" = true;
        "ultima.urlbar.suggestions" = true;
        "ultima.urlbar.centered" = true;
        "ultima.xstyle.containertabs.111" = true;
        "ultima.xstyle.pinnedtabs.1" = true;
        "ultima.OS.mac" = true;
        "browser.uidensity" = 0;
        "browser.aboutConfig.showWarning" = false;
        "browser.tabs.hoverPreview.enabled" = true;
        "user.theme.dark.catppuccin-mocha" = true;
      };
      theme = {
        font = config.stylix.fonts.serif.name;

        defaultUserChrome.enable = false;
        defaultUserContent.enable = false;

        extraUserChrome =
          # css
          ''

            @import url(theme/all-global-positioning.css);

            @import url(theme/all-color-schemes.css);

            @import url(theme/position-tabs.css);
            @import url(theme/position-findbar.css);
            @import url(theme/position-window-controls.css);

            @import url(theme/function-mini-button-bar.css);
            @import url(theme/function-sidebar-autohide.css);
            @import url(theme/function-containers-indicator.css);
            @import url(theme/function-menu-button.css);
            @import url(theme/function-privatemode-indicator.css);
            @import url(theme/function-urlbar.css);
            @import url(theme/function-extensions-menu.css);
            @import url(theme/function-safeguard.css);

            @import url(theme/theme-context-menu.css);
            @import url(theme/theme-menubar.css);
            @import url(theme/theme-statuspanel.css);
            @import url(theme/theme-PIP.css);
            @import url(theme/theme-tab-audio-indicator.css);

            @import url(theme/override-linux.css);
            @import url(theme/override-mac.css);
            @import url(theme/override-styles.css);
            * {font-family: "Poppins" !important;}
          '';
        extraUserContent =
          # css
          ''
            @import url(theme/z-site-styles.css);

            @import url(theme/z-site-newtab.css);

            @import url(theme/z-site-reddit.css);

            @import url(theme/z-site-yt.css);

            /*@import url(theme/z-sites.css);*/

          '';
      };
    };
    home.file = {
      ".mozilla/firefox/schizo.default/chrome/theme/".source = inputs.ff-ultima.outPath + "/theme/";
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
