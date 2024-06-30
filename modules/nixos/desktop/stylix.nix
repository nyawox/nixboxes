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
        url = "https://i.pinimg.com/originals/24/ca/db/24cadbfc4de7599a86ef5e8bc238853e.jpg";
        sha256 = "1fraqngiw0l164i1ar7i3bzq0bz7zdcvydqgxrr0rqqq3y4rq6sv";
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
        name = "Catppuccin-Mocha-Pink-Cursors";
        size = 16;
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
