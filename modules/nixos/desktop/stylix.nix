{
  lib,
  config,
  pkgs,
  inputs,
  username,
  ...
}:
with lib; let
  cfg = config.modules.desktop.stylix;
in {
  imports = [inputs.stylix.nixosModules.stylix];
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
        url = "https://raw.githubusercontent.com/Keyitdev/sddm-astronaut-theme/master/background.png";
        sha256 = "1bvfc33gw6hj7s6dk6hzsn4aq2ymmjvyx4qgwnnl4k9gg29g12im";
      };
      base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
      fonts = {
        serif = {
          package = pkgs.poppins;
          name = "Poppins";
        };

        sansSerif = {
          package = pkgs.poppins;
          name = "Poppins";
        };

        monospace = {
          package = pkgs.spleen;
          name = "Spleen-6x12";
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
        name = "catppuccin-mocha-pink-cursors";
        size = 24;
      };
      opacity = {
        applications = 0.75;
        terminal = 0.75;
      };
      targets = {
        console.enable = false;
        grub.enable = false;
      };
    };
    home-manager.users."${username}".stylix = {
      targets = {
        waybar.enable = false;
        emacs.enable = false;
        alacritty.enable = false;
        foot.enable = false;
        helix.enable = false;
        zellij.enable = false;
        fzf.enable = false;
        fuzzel.enable = false;
      };
    };
  };
}
