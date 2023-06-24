{
  wayland.windowManager.hyprland.extraConfig = ''
    env = XCURSOR_SIZE,24

    # Wayland compatibility
    env = QT_QPA_PLATFORM,wayland
    env = QT_WAYLAND_DISABLE_WINDOWDECORATION,1
    env = QT_ENABLE_HIGHDPI_SCALING,1
    env = CLUTTER_BACKEND,wayland
    env = GDK_BACKEND,wayland
    env = GDK_SCALE,0.75
    env = MOZ_ENABLE_WAYLAND,1
    env = MOZ_WEBRENDER,1
    env = SDL_VIDEODRIVER,wayland
    env = XDG_CURRENT_DESKTOP,Hyprland
    env = XDG_SESSION_TYPE,wayland
    env = XDG_SESSION_DESKTOP,Hyprland
    env = XDG_CURRENT_DESKTOP,Hyprland
    env = GSETTINGS_BACKEND,keyfile

    env = WLR_NO_HARDWARE_CURSORS,1

    # QT-related theming
    env = QT_QPA_PLATFORMTHEME,qt6ct

    # FCITX input-related
    env = GTK_IM_MODULE,fcitx5
    env = QT_IM_MODULE,fcitx5
    env = XMODIFIERS=@im,fcitx5
    env = GTK_USE_PORTAL,1
    env = GLFW_IM_MODULE,fcitx5
    env = INPUT_METHOD,fcitx5
    env = IMSETTINGS_MODULE,fcitx5
  '';
}
