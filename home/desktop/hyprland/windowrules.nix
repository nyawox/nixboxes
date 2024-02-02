{
  wayland.windowManager.hyprland.extraConfig = ''
    # Example windowrule v1
    # windowrule = float, ^(kitty)$
    # Example windowrule v2
    # windowrulev2 = float,class:^(kitty)$,title:^(kitty)$
    # See https://wiki.hyprland.org/Configuring/Window-Rules/ for more

    windowrulev2 = opacity 0.85 0.85,class:^(firefox)$
    windowrulev2 = opacity 0.85 0.85,class:^(floorp)$
    windowrulev2 = opacity 0.85 0.85,class:^(librewolf)$
    windowrulev2 = opacity 0.8 0.85,class:^(Alacritty)$
    windowrulev2 = opacity 0.8 0.85,class:^(org.wezfurlong.wezterm)$
    windowrulev2 = opacity 0.8 0.70,class:^(emacs)$
    windowrulev2 = opacity 0.8 0.75,class:^(org.gnome.Nautilus)$
    windowrulev2 = opacity 0.8 0.75,class:^(lutris)$
    windowrulev2 = opacity 0.8 0.75,class:^(pavucontrol)$
    windowrulev2 = opacity 0.8 0.75,class:^(valent)$
    windowrulev2 = opacity 0.8 0.75,class:^(.blueman-manager-wrapped)$
    windowrulev2 = opacity 0.8 0.75,class:^(discord)$
    windowrulev2 = opacity 0.8 0.75,class:^(VencordDesktop)$
    windowrule = workspace 10 silent, title:^(Steam)$
    windowrule = workspace 10 silent, title:^(Steam Big Picture Mode)$
    windowrule = workspace 10 silent, title:^(Steam Big Pictureモード)$
    windowrule = workspace 10 silent, class:^(.gamescope-wrapped)$
    windowrule = fullscreen, title:^(Steam)$
    windowrule = fullscreen, title:^(Steam Big Picture Mode)$
    windowrule = fullscreen, title:^(Steam Big Pictureモード)$
    windowrule = fullscreen, class:^(.gamescope-wrapped)$
    windowrule = float, class:^(Uget-gtk)$
    windowrule = float, title:^(uGet)$
  '';
}
