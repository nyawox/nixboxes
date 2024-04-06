_: {
  wayland.windowManager.hyprland.extraConfig = ''

    # See https://wiki.hyprland.org/Configuring/Monitors/
    monitor=DP-1, modeline 172.48 1920 1928 1960 2000 1080 1106 1114 1120 +hsync -vsync,0x0,1
    monitor=HDMI-A-1,1920x1080@60,1920x0,1
    workspace=DP-1,1
    workspace=HDMI-A-1,2

    # For all categories, see https://wiki.hyprland.org/Configuring/Variables/
    input {
        kb_model =
        kb_options =
        kb_rules =

        follow_mouse = 1

        touchpad {
            natural_scroll = no
        }

        sensitivity = 0 # -1.0 - 1.0, 0 means no modification.
    }

  '';
}
