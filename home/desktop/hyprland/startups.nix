{pkgs, ...}: {
  wayland.windowManager.hyprland.extraConfig = ''
    exec-once = dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
    exec-once = hyprctl setcursor Catppuccin-Mocha-Pink-Cursors 16
    exec-once = waybar
    exec-once = fcitx5
    exec-once = ${pkgs.swaynotificationcenter}/bin/swaync
    exec-once = configure-gtk
  '';
}
