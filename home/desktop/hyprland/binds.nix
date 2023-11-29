{pkgs, ...}: {
  wayland.windowManager.hyprland.extraConfig = ''
    # $mainMod = SUPER

    bind = SUPER, RETURN, exec, wezterm
    bind = SUPER, C, killactive,
    bind = SUPER, M, exit,
    bind = SUPER, E, exec, nautilus --new-window
    bind = SUPER, W, exec, emacsclient -c
    bind = SUPER, B, exec, firefox
    bind = SUPER, N, exec, swaync-client -t -sw
    bind = SUPER, V, togglefloating,
    bind = SUPER, R, exec, ${pkgs.wofi}/bin/wofi -H 1000 -S drun -I
    bind = SUPER, SPACE, exec, ${pkgs.nwg-drawer}/bin/nwg-drawer -term wezterm -fm nautilus -ovl
    bind = SUPER, P, pseudo, # dwindle
    bind = SUPER, X, togglesplit, # dwindle
    bind = SUPER, O, exec, swaylock --screenshots --clock --indicator --indicator-radius 100 --indicator-thickness 7 --effect-blur 7x5 --effect-vignette 0.5:0.5 --ring-color f5c2e7 --text-color cdd6f4 --key-hl-color fab387 --line-color 00000000 --inside-color 1e1e2e88 --separator-color 00000000 --grace 2 --fade-in 0.2
    bind = SUPER, S, exec, ${pkgs.slurp}/bin/slurp | ${pkgs.grim}/bin/grim -g - $(xdg-user-dir PICTURES)/$(date +'screenshot_%Y-%m-%d-%H%M%S.png')

    # Move focus with mainMod + arrow keys
    bind = SUPER, h, movefocus, l
    bind = SUPER, l, movefocus, r
    bind = SUPER, k, movefocus, u
    bind = SUPER, j, movefocus, d

    # Move windows
    bind = SUPER SHIFT, H, movewindow, l
    bind = SUPER SHIFT, L, movewindow, r
    bind = SUPER SHIFT, K, movewindow, u
    bind = SUPER SHIFT, J, movewindow, d

    bind = SUPER CTRL, H, resizeactive, -80 0
    bind = SUPER CTRL, L, resizeactive, 80 0
    bind = SUPER CTRL, K, resizeactive, 0 -80
    bind = SUPER CTRL, J, resizeactive, 0 80
    bind = SUPER CTRL SHIFT, H, moveactive,  -80 0
    bind = SUPER CTRL SHIFT, L, moveactive, 80 0
    bind = SUPER CTRL SHIFT, K, moveactive, 0 -80
    bind = SUPER CTRL SHIFT, J, moveactive, 0 80

    # Fullscreen
    bind = SUPER, F, fullscreen

    # Focus monitor with mainMod + ,/.
    bind = SUPER, 25, focusmonitor, 0
    bind = SUPER, 26, focusmonitor, 1

    # Move active window to a monitor with mainMod + SHIFT + ,/.
    bind = SUPER SHIFT, 25, movewindow, mon:0
    bind = SUPER SHIFT, 26, movewindow, mon:1

    # Control brightness
    bind=,XF86MonBrightnessDown,exec,/run/current-system/sw/bin/light -U 10
    bind=,XF86MonBrightnessUp,exec,/run/current-system/sw/bin/light -A 10

    # Switch workspaces with mainMod + [0-9]
    bind = SUPER, 1, workspace, 1
    bind = SUPER, 2, workspace, 2
    bind = SUPER, 3, workspace, 3
    bind = SUPER, 4, workspace, 4
    bind = SUPER, 5, workspace, 5
    bind = SUPER, 6, workspace, 6
    bind = SUPER, 7, workspace, 7
    bind = SUPER, 8, workspace, 8
    bind = SUPER, 9, workspace, 9
    bind = SUPER, 0, workspace, 10

    # Move active window to a workspace with mainMod + SHIFT + [0-9]
    bind = SUPER SHIFT, 1, movetoworkspace, 1
    bind = SUPER SHIFT, 2, movetoworkspace, 2
    bind = SUPER SHIFT, 3, movetoworkspace, 3
    bind = SUPER SHIFT, 4, movetoworkspace, 4
    bind = SUPER SHIFT, 5, movetoworkspace, 5
    bind = SUPER SHIFT, 6, movetoworkspace, 6
    bind = SUPER SHIFT, 7, movetoworkspace, 7
    bind = SUPER SHIFT, 8, movetoworkspace, 8
    bind = SUPER SHIFT, 9, movetoworkspace, 9
    bind = SUPER SHIFT, 0, movetoworkspace, 10

    # Scroll through existing workspaces with mainMod + scroll
    bind = SUPER, mouse_down, workspace, e+1
    bind = SUPER, mouse_up, workspace, e-1

    # Move/resize windows with mainMod + LMB/RMB and dragging
    bindm = SUPER, mouse:272, movewindow
    bindm = SUPER, mouse:273, resizewindow
  '';
}
