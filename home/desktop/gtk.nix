{
  pkgs,
  lib,
  ...
}: let
  configure-gtk = pkgs.writeTextFile {
    name = "configure-gtk";
    destination = "/bin/configure-gtk";
    executable = true;
    text = let
      schema = pkgs.gsettings-desktop-schemas;
      datadir = "${schema}/share/gsettings-schemas/${schema.name}";
    in ''
      export XDG_DATA_DIRS=${datadir}:$XDG_DATA_DIRS
      gnome_schema=org.gnome.desktop.interface
      gsettings set $gnome_schema icon-theme 'WhiteSur-dark'
      gsettings set $gnome_schema cursor-theme 'Catppuccin-Mocha-Pink-Cursors'
      gsettings set $gnome_schema font-name 'IBM Plex Sans 9'
      gsettings set $gnome_schema color-scheme prefer-dark
    '';
  };
in {
  gtk = {
    enable = true;
    theme = lib.mkForce {
      name = "Catppuccin-Mocha-Standard-Pink-Dark";
      package = pkgs.catppuccin-gtk.override {
        accents = ["blue" "pink"];
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
  home.packages = with pkgs; [glib configure-gtk];
}
