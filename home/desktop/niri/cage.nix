# Check desktop entries in /run/current-system/sw/share/applications
# or /etc/profiles/per-user/nyaa/share/applications/
{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.modules.desktop.cage;
in {
  options = {
    modules.desktop.cage = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };
  config = mkIf cfg.enable {
    home.packages = [pkgs.cage];
    xdg.desktopEntries = let
      capitalize = s: "${toUpper (substring 0 1 s)}${substring 1 (-1) s}";
      makeEntry = program: args: optionalName: {
        name =
          if optionalName == null
          then capitalize program
          else optionalName;
        icon = program;
        exec = "${pkgs.cage}/bin/cage ${pkgs.${program}}/bin/${program} ${args}";
      };
    in {
      netflix.exec = lib.mkForce "${pkgs.cage}/bin/cage ${pkgs.vivaldi}/bin/vivaldi -- --ozone-platform=x11 --app=https://www.netflix.com --no-first-run --no-default-browser-check --no-crash-upload";
      vesktop = makeEntry "vesktop" "-- --ozone-platform=x11 %u" null;
      cider = makeEntry "cider" "-- --ozone-platform=x11 %u" null;
      obsidian = makeEntry "obsidian" "-- --ozone-platform=x11 %u" null;
      youtube-music = makeEntry "youtube-music" "-- --ozone-platform=x11 %u" "Youtube Music";
      vivaldi-stable = {
        name = "Vivaldi";
        icon = "vivaldi";
        exec = "${pkgs.cage}/bin/cage ${pkgs.vivaldi}/bin/vivaldi -- --ozone-platform=x11 %u";
      };
      element-desktop = {
        name = "Element";
        icon = "element";
        exec = "${pkgs.cage}/bin/cage ${pkgs.element-desktop}/bin/element-desktop -- --ozone-platform=x11 %u";
      };
      onlyoffice-desktopeditors = {
        name = "ONLYOFFICE Desktop Editors";
        icon = "onlyoffice-desktopeditors";
        exec = "${pkgs.cage}/bin/cage ${pkgs.onlyoffice-bin}/bin/DesktopEditors -- %u";
        mimeType = [
          "application/vnd.oasis.opendocument.text"
          "application/vnd.oasis.opendocument.spreadsheet"
          "application/vnd.oasis.opendocument.presentation"
          "application/vnd.oasis.opendocument.graphics"
          "application/vnd.ms-word"
          "application/vnd.ms-excel"
          "application/vnd.ms-powerpoint"
          "application/msword"
          "application/excel"
          "application/mspowerpoint"
          "application/powerpoint"
          "application/vnd.ms-office"
          "application/zip"
          "application/x-zip"
          "application/x-zip-compressed"
          "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
          "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
          "application/vnd.openxmlformats-officedocument.presentationml.presentation"
          "application/vnd.openxmlformats-officedocument.presentationml.slideshow"
          "application/vnd.openxmlformats-officedocument.presentationml.template"
          "application/vnd.openxmlformats-officedocument.spreadsheetml.template"
          "application/vnd.openxmlformats-officedocument.wordprocessingml.template"
          "application/vnd.ms-excel.sheet.macroenabled.12"
          "application/vnd.ms-excel.template.macroenabled.12"
          "application/vnd.ms-excel.addin.macroenabled.12"
          "application/vnd.ms-excel.sheet.binary.macroenabled.12"
          "application/vnd.ms-word.document.macroenabled.12"
          "application/vnd.ms-word.template.macroenabled.12"
          "application/vnd.ms-powerpoint.template.macroenabled.12"
          "application/vnd.ms-powerpoint.slideshow.macroenabled.12"
          "application/vnd.ms-powerpoint.addin.macroenabled.12"
          "application/vnd.ms-powerpoint.presentation.macroenabled.12"
        ];
      };
    };
  };
}
