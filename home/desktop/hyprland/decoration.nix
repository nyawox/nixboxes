{
  wayland.windowManager.hyprland.settings = {
    decoration = {
      # See https://wiki.hyprland.org/Configuring/Variables/ for more
      rounding = 8;
      blur = {
        enabled = true;
        size = 7;
        passes = 4;
        new_optimizations = true;
      };

      drop_shadow = true;
      shadow_range = 4;
      shadow_render_power = 3;
    };
  };
}
