{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.modules.desktop.mpv;
in {
  options = {
    modules.desktop.mpv = {
      enable = mkOption {
        type = types.bool;
        default = true;
      };
    };
  };
  config = mkIf cfg.enable {
    programs.mpv = {
      enable = true;
      bindings = {
        "h" = "seek -10";
        "l" = "seek 10";
        "j" = "add volume -2";
        "k" = "add volume 2";
      };
      config = {
        profile = "gpu-hq";
        ytdl-format = "bestvideo+bestaudio";
      };
      scripts = [
        pkgs.mpvScripts.sponsorblock
        pkgs.mpvScripts.quality-menu
      ];
    };
    home.packages = with pkgs; [yt-dlp];
  };
}
