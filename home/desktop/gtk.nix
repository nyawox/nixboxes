{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.modules.desktop.gtk;
in {
  options = {
    modules.desktop.gtk = {
      enable = mkOption {
        type = types.bool;
        default = true;
      };
    };
  };
  config = mkIf cfg.enable {
    gtk = {
      enable = true;
      theme = lib.mkForce {
        name = "Catppuccin-Mocha-Standard-Pink-Dark";
        package = pkgs.catppuccin-gtk.override {
          accents = [
            "blue"
            "pink"
          ];
          size = "standard";
          tweaks = ["rimless"];
          variant = "mocha";
        };
      };
      iconTheme = {
        name = "WhiteSur-dark";
        package = pkgs.whitesur-icon-theme.override {
          alternativeIcons = true;
          boldPanelIcons = true;
        };
      };
      cursorTheme = {
        name = "Catppuccin-Mocha-Pink-Cursors";
        package = pkgs.catppuccin-cursors.mochaPink;
        size = 16;
      };
    };
    home.packages = with pkgs; [glib];
  };
}
