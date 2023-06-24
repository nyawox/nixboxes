{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.modules.desktop.vivaldi;
in
{
  options = {
    modules.desktop.vivaldi = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };
  config = mkIf cfg.enable {
    programs.chromium = {
      enable = true;
      package = pkgs.vivaldi;
      extensions = [
        { id = "mdlbikciddolbenfkgggdegphnhmnfcg"; } # netflix 1080p
        { id = "eimadpbcbfnmbkopoojfekhnkhdbieeh"; } # darkreader, used for apple music
      ];
    };
    xdg.desktopEntries = {
      netflix = {
        name = "Netflix";
        comment = "Open Netflix in Vivaldi Browser";
        exec = "${getExe pkgs.vivaldi} --app=https://www.netflix.com --no-first-run --no-default-browser-check --no-crash-upload";
        icon = pkgs.fetchurl {
          name = "netflix-icon-2016.png";
          url = "https://assets.nflxext.com/us/ffe/siteui/common/icons/nficon2016.png";
          sha256 = "sha256-c0H3uLCuPA2krqVZ78MfC1PZ253SkWZP3PfWGP2V7Yo=";
        };
        type = "Application";
        categories = [
          "TV"
          "AudioVideo"
          "Network"
        ];
      };
      # applemusic = {
      #   name = "Apple Music";
      #   comment = "Open Apple Music in Vivaldi Browser";
      #   exec = "${getExe pkgs.vivaldi} --app=https://beta.music.apple.com --no-first-run --no-default-browser-check --no-crash-upload";
      #   icon = pkgs.fetchurl {
      #     name = "apple-music-icon.png";
      #     url = "https://music.apple.com/assets/favicon/favicon-180.png";
      #     sha256 = "sha256-lZXt+kbYCBTLzK1S9QcxVwIhin2x8iNUAcrSHtmWmOY=";
      #     meta.license = lib.licenses.unfree;
      #   };
      #   type = "Application";
      #   categories = ["AudioVideo"];
      # };
    };
  };
}
