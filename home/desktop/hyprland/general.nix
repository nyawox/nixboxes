{
  lib,
  pkgs,
  inputs,
  ...
}: {
  home.packages = with pkgs; [
    qt5.qtwayland
    qt6.qtwayland
    qt6ct
    wlr-randr
    xdg-user-dirs
    foot
  ];
  wayland.windowManager.hyprland = {
    enable = lib.mkDefault true;
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;
    systemd.enable = lib.mkDefault true;
    xwayland.enable = lib.mkDefault true;
    plugins = [
      inputs.hyprfocus.packages.${pkgs.system}.default
    ];
    settings = {
      general = {
        # See https://wiki.hyprland.org/Configuring/Variables/ for more
        gaps_in = 5;
        gaps_out = 10;
        border_size = 4;
        "col.active_border" = lib.mkForce "rgb(f5c2e7)";

        layout = "dwindle";
      };
      # unscale XWayland
      xwayland = {
        force_zero_scaling = true;
      };
      dwindle = {
        # See https://wiki.hyprland.org/Configuring/Dwindle-Layout/ for more
        pseudotile = true; # master switch for pseudotiling. Enabling is bound to mainMod + P in the keybinds section below
        preserve_split = true; # you probably want this
      };
      master = {
        # See https://wiki.hyprland.org/Configuring/Master-Layout/ for more
        new_is_master = true;
      };
      gestures = {
        # See https://wiki.hyprland.org/Configuring/Variables/ for more
        workspace_swipe = true;
      };
      misc = {
        enable_swallow = true;
        swallow_regex = "^(Alacritty|org.wezfurlong.wezterm|kitty|footclient)$";
      };
      # Example per-device config
      # See https://wiki.hyprland.org/Configuring/Keywords/#executing for more
      "device:epic-mouse-v1" = {
        sensitivity = "-0.5";
      };
    };
  };
}
