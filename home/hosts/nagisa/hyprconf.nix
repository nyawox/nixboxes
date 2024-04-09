_: {
  wayland.windowManager.hyprland.extraConfig = ''

    # See https://wiki.hyprland.org/Configuring/Monitors/
    monitor=eDP-1,1366x768@60,0x0,1

    # For all categories, see https://wiki.hyprland.org/Configuring/Variables/
    input {

        follow_mouse = 1

        touchpad {
            natural_scroll = yes
        }

        sensitivity = 0
    }

  '';
}
