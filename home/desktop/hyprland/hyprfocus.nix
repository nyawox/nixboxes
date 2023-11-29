{
  wayland.windowManager.hyprland.extraConfig = ''
    plugin:hyprfocus {
        enabled = yes

        keyboard_focus_animation = flash
        mouse_focus_animation = flash

        bezier = bezIn, 0.5,0.0,1.0,0.5
        bezier = bezOut, 0.0,0.5,0.5,1.0

        flash {
            flash_opacity = 0.7

            in_bezier = bezIn
            in_speed = 1

            out_bezier = bezOut
            out_speed = 4
        }

        shrink {
            shrink_percentage = 0.8

            in_bezier = bezIn
            in_speed = 0.5

            out_bezier = bezOut
            out_speed = 3
        }
    }
  '';
}
