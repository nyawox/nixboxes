{username, ...}: {
  wayland.windowManager.hyprland.extraConfig = ''
    exec-once=dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
    exec-once = waybar
    exec-once = fcitx5
    exec-once = swww init
    exec-once = swww img --transition-type grow --transition-pos top --transition-fps 75 /home/${username}/.wallpaper.png
    exec-once = swaync
    exec-once = configure-gtk
    exec-once = nwg-look -a
    exec-once = hyprctl setcursor Catppuccin-Mocha-Pink 32
  '';
}
