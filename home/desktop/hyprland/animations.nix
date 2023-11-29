{
  wayland.windowManager.hyprland.extraConfig = ''
    animations {
        #see https://wiki.hyprland.org/Configuring/Animations/ for more
        enabled = yes
        bezier = win, 0.13, 0.99, 0.29, 1.1
        bezier = winOut, 0.3, -0.3, 0, 1
        bezier = linear, 1, 1, 1, 1
        animation = windows, 1, 4, win, slide
        animation = windowsIn, 1, 4, win, slide
        animation = windowsOut, 1, 4, winOut, popin 80%
        animation = windowsMove, 1, 7, win, slide
        animation = border, 1, 5, default
        animation = borderangle, 1, 30, linear, loop
        animation = fade, 1, 8, default
        animation = workspaces, 1, 6, win, slidevert
    }
  '';
}
