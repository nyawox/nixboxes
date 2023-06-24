{pkgs, ...}: let
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
in {
  programs.firefox = {
    enable = true;
    package = pkgs.firefox.override {
      nativeMessagingHosts = with pkgs; [
        uget-integrator
        tridactyl-native
      ];
      extraPrefs = ''
        // Downloading random PDFs from http website is super annoing with this.
        lockPref("dom.block_download_insecure", false);

        // Always use XDG portals for stuff
        lockPref("widget.use-xdg-desktop-portal.file-picker", 1);

        // Enable userChrome.css
        lockPref("toolkit.legacyUserProfileCustomizations.stylesheets", true);

        // Avoid cluttering ~/Downloads for the “Open” action on a file to download.
        lockPref("browser.download.start_downloads_in_tmp_dir", true);

        // Automatically enable extensions installed by home-manager
        lockPref("extensions.autoDisableScopes",0)
      '';
      extraPolicies = {
        "OverrideFirstRunPage" = "";
        "OverridePostUpdatePage" = "";
      };
    };
    profiles.default = {
      name = "default";
      isDefault = true;

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
      ];

      search = {
        default = "Google";
        force = true;
        engines = {
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
        "browser.startup.homepage" = "https://homepage.nixhome.shop";
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
      pkgs.fetchFromGitHub cascade-repo
      + "/integrations/catppuccin/catppuccin-mocha.css";
    ".mozilla/firefox/default/chrome/includes/cascade-layout.css".source =
      pkgs.fetchFromGitHub cascade-repo + "/chrome/includes/cascade-layout.css";
    ".mozilla/firefox/default/chrome/includes/cascade-responsive.css".source =
      pkgs.fetchFromGitHub cascade-repo
      + "/chrome/includes/cascade-responsive.css";
    ".mozilla/firefox/default/chrome/includes/cascade-floating-panel.css".source =
      pkgs.fetchFromGitHub cascade-repo
      + "/chrome/includes/cascade-floating-panel.css";
    ".mozilla/firefox/default/chrome/includes/cascade-nav-bar.css".source =
      pkgs.fetchFromGitHub cascade-repo + "/chrome/includes/cascade-nav-bar.css";
    ".mozilla/firefox/default/chrome/includes/cascade-tabs.css".source =
      pkgs.fetchFromGitHub cascade-repo + "/chrome/includes/cascade-tabs.css";
  };

  xdg.configFile."tridactyl/tridactylrc".source = ./tridactylrc;
  xdg.configFile."tridactyl/themes/catppuccin.css".source =
    pkgs.fetchFromGitHub catppuccin-tridactyl + "/catppuccin.css";
}
