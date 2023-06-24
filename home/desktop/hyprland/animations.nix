{
  wayland.windowManager.hyprland.extraConfig = ''
    animations {
        #see https://wiki.hyprland.org/Configuring/Animations/ for more
        enabled = yes
        bezier = win, 0.05, 0.9, 0.1, 1.05
        bezier = winIn, 0.1, 1.1, 0.1, 1.1
        bezier = winOut, 0.3, -0.3, 0, 1
        bezier = linear, 1, 1, 1, 1
        animation = windows, 1, 8, win, slide
        animation = windowsIn, 1, 8, winIn, slide
        animation = windowsOut, 1, 7, winOut, slide
        animation = windowsMove, 1, 7, win, slide
        animation = border, 1, 1, linear
        animation = borderangle, 1, 30, linear, loop
        animation = fade, 1, 10, default
        animation = workspaces, 1, 7, win
    }
  '';
}
