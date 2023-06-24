_: {
  wayland.windowManager.hyprland.extraConfig = ''

    # See https://wiki.hyprland.org/Configuring/Monitors/
    monitor=eDP-1,1366x768@60,0x0,0.7115

    # For all categories, see https://wiki.hyprland.org/Configuring/Variables/
    input {
        kb_model =
        kb_options = ctrl:nocaps,altwin:swap_alt_win
        kb_rules =

        follow_mouse = 1

        touchpad {
            natural_scroll = yes
        }

        sensitivity = 0
    }

    device:tpps/2-ibm-trockpoint {
        sensitivity = -1
    }

  '';
}
