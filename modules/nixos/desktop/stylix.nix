{
  config,
  lib,
  pkgs,
  username,
  ...
}:
with lib; let
  cfg = config.modules.desktop.stylix;
in {
  options = {
    modules.desktop.stylix = {
      enable = mkOption {
        type = types.bool;
        default = true;
      };
    };
  };
  config = mkIf cfg.enable {
    stylix = {
      polarity = "dark";
      image = pkgs.fetchurl {
        url = "https://www.pixelstalk.net/wp-content/uploads/images8/Desktop-Wallpaper-Free-Download.jpg";
        sha256 = "11k6n82l09gnvr885y71pngvwqw48n9vwwa7zx2hgh4r6wmb05gn";
      };
      base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
      fonts = {
        serif = {
          package = pkgs.ibm-plex;
          name = "IBM Plex Serif";
        };

        sansSerif = {
          package = pkgs.ibm-plex;
          name = "IBM Plex Sans";
        };

        monospace = {
          package = pkgs.nerdfonts.override {fonts = ["IBMPlexMono"];};
          name = "BlexMono Nerd Font";
        };

        emoji = {
          package = pkgs.apple-emoji;
          name = "Apple Color Emoji";
        };
        sizes = {
          applications = 9;
          desktop = 9;
          popups = 9;
          terminal = 9;
        };
      };
      cursor = {
        package = pkgs.catppuccin-cursors.mochaPink;
        name = "Catppuccin-Mocha-Pink-Cursors";
        size = 16;
      };
      opacity = {
        applications = 0.75;
        terminal = 0.75;
      };
    };
    home-manager.users."${username}".stylix = {
      targets = {
        waybar.enable = false;
        emacs.enable = false;
        alacritty.enable = false;
      };
    };
  };
}
