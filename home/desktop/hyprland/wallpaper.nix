{
  pkgs,
  username,
  ...
}: {
  home.packages = with pkgs; [
    hyprpaper
  ];
  wayland.windowManager.hyprland.extraConfig = ''
    exec-once = hyprpaper
  '';
  xdg.configFile."hypr/hyprpaper.conf".text = ''
    preload = /home/${username}/.wallpaper.jpg
    wallpaper = ,/home/${username}/.wallpaper.jpg
  '';
}
