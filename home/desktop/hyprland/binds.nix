{pkgs, ...}: {
  wayland.windowManager.hyprland.extraConfig = ''
    $mainMod = SUPER

    bind = $mainMod, RETURN, exec, wezterm
    bind = $mainMod, C, killactive,
    bind = $mainMod, M, exit,
    bind = $mainMod, E, exec, nautilus --new-window
    bind = $mainMod, W, exec, emacsclient -c
    bind = $mainMod, B, exec, firefox
    bind = $mainMod, N, exec, swaync-client -t -sw
    bind = $mainMod, V, togglefloating,
    bind = $mainMod, R, exec, ${pkgs.wofi}/bin/wofi -H 1200 -S drun -I
    bind = $mainMod, SPACE, exec, ${pkgs.nwg-drawer}/bin/nwg-drawer -term wezterm -fm nautilus -ovl
    bind = $mainMod, P, pseudo, # dwindle
    bind = $mainMod, X, togglesplit, # dwindle
    bind = $mainMod, O, exec, swaylock --screenshots --clock --indicator --indicator-radius 100 --indicator-thickness 7 --effect-blur 7x5 --effect-vignette 0.5:0.5 --ring-color f5c2e7 --text-color cdd6f4 --key-hl-color fab387 --line-color 00000000 --inside-color 1e1e2e88 --separator-color 00000000 --grace 2 --fade-in 0.2
    bind = $mainMod, S, exec, ${pkgs.slurp}/bin/slurp | ${pkgs.grim}/bin/grim -g - $(xdg-user-dir PICTURES)/$(date +'screenshot_%Y-%m-%d-%H%M%S.png')

    # Move focus with mainMod + arrow keys
    bind = $mainMod, h, movefocus, l
    bind = $mainMod, l, movefocus, r
    bind = $mainMod, k, movefocus, u
    bind = $mainMod, j, movefocus, d

    # Move windows
    bind = $mainMod SHIFT, H, movewindow, l
    bind = $mainMod SHIFT, L, movewindow, r
    bind = $mainMod SHIFT, K, movewindow, u
    bind = $mainMod SHIFT, J, movewindow, d

    # Fullscreen
    bind = $mainMod, F, fullscreen

    # Focus monitor with mainMod + ,/.
    bind = $mainMod, 25, focusmonitor, 0
    bind = $mainMod, 26, focusmonitor, 1

    # Move active window to a monitor with mainMod + SHIFT + ,/.
    bind = $mainMod SHIFT, 25, movewindow, mon:0
    bind = $mainMod SHIFT, 26, movewindow, mon:1

    # Control brightness
    bind=,XF86MonBrightnessDown,exec,/run/current-system/sw/bin/light -U 10
    bind=,XF86MonBrightnessUp,exec,/run/current-system/sw/bin/light -A 10

    # Switch workspaces with mainMod + [0-9]
    bind = $mainMod, 1, workspace, 1
    bind = $mainMod, 2, workspace, 2
    bind = $mainMod, 3, workspace, 3
    bind = $mainMod, 4, workspace, 4
    bind = $mainMod, 5, workspace, 5
    bind = $mainMod, 6, workspace, 6
    bind = $mainMod, 7, workspace, 7
    bind = $mainMod, 8, workspace, 8
    bind = $mainMod, 9, workspace, 9
    bind = $mainMod, 0, workspace, 10

    # Move active window to a workspace with mainMod + SHIFT + [0-9]
    bind = $mainMod SHIFT, 1, movetoworkspace, 1
    bind = $mainMod SHIFT, 2, movetoworkspace, 2
    bind = $mainMod SHIFT, 3, movetoworkspace, 3
    bind = $mainMod SHIFT, 4, movetoworkspace, 4
    bind = $mainMod SHIFT, 5, movetoworkspace, 5
    bind = $mainMod SHIFT, 6, movetoworkspace, 6
    bind = $mainMod SHIFT, 7, movetoworkspace, 7
    bind = $mainMod SHIFT, 8, movetoworkspace, 8
    bind = $mainMod SHIFT, 9, movetoworkspace, 9
    bind = $mainMod SHIFT, 0, movetoworkspace, 10

    # Scroll through existing workspaces with mainMod + scroll
    bind = $mainMod, mouse_down, workspace, e+1
    bind = $mainMod, mouse_up, workspace, e-1

    # Move/resize windows with mainMod + LMB/RMB and dragging
    bindm = $mainMod, mouse:272, movewindow
    bindm = $mainMod, mouse:273, resizewindow
  '';
}
