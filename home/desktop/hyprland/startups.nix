{pkgs, ...}: {
  wayland.windowManager.hyprland.extraConfig = ''
    exec-once=dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
    exec-once = waybar
    exec-once = fcitx5
    exec-once = ${pkgs.swaynotificationcenter}/bin/swaync
    exec-once = configure-gtk
    exec-once = ${pkgs.nwg-look}/bin/nwg-look -a
    exec-once = hyprctl setcursor Catppuccin-Mocha-Pink 32
  '';
}
