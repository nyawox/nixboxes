{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.modules.desktop.vivaldi;
in {
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
        {id = "mdlbikciddolbenfkgggdegphnhmnfcg";} # netflix 1080p
      ];
    };
    xdg.desktopEntries.netflix = {
      name = "Netflix";
      comment = "Open Netflix in Vivaldi Browser";
      exec = "${pkgs.vivaldi}/bin/vivaldi --app=https://www.netflix.com --no-first-run --no-default-browser-check --no-crash-upload";
      icon = pkgs.fetchurl {
        name = "netflix-icon-2016.png";
        url = "https://assets.nflxext.com/us/ffe/siteui/common/icons/nficon2016.png";
        sha256 = "sha256-c0H3uLCuPA2krqVZ78MfC1PZ253SkWZP3PfWGP2V7Yo=";
      };
      type = "Application";
      categories = ["TV" "AudioVideo" "Network"];
    };
  };
}
