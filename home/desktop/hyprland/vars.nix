{lib, ...}: {
  home.sessionVariables = {
    XCURSOR_SIZE = 24;

    # Wayland compatibility
    QT_QPA_PLATFORM = "wayland";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = 1;
    QT_ENABLE_HIGHDPI_SCALING = 1;
    CLUTTER_BACKEND = "wayland";
    GDK_BACKEND = "wayland";
    GDK_SCALE = 0.75;
    MOZ_ENABLE_WAYLAND = 1;
    MOZ_WEBRENDER = 1;
    SDL_VIDEODRIVER = "wayland";
    XDG_SESSION_TYPE = "wayland";
    XDG_SESSION_DESKTOP = "Hyprland";
    XDG_CURRENT_DESKTOP = "Hyprland";
    GSETTINGS_BACKEND = "keyfile";

    WLR_NO_HARDWARE_CURSORS = 1;

    # FCITX input-related
    GTK_IM_MODULE = lib.mkForce "";
    GTK_USE_PORTAL = 1;
    INPUT_METHOD = "fcitx5";
    IMSETTINGS_MODULE = "fcitx5";
  };
}
