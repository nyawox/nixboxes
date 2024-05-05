{
  config,
  lib,
  osConfig,
  ...
}:
with lib; {
  config = mkIf osConfig.modules.desktop.cosmic.enable {
    home.sessionVariables = {
      # force wayland
      NIXOS_OZONE_WL = "1";
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1"; # Disables window decorations on Qt applications
      GTK_THEME = config.gtk.theme.name;
    };
  };
}
