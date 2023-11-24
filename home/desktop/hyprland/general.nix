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
  ];
  wayland.windowManager.hyprland = {
    enable = lib.mkDefault true;
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;
    systemd.enable = lib.mkDefault true;
    xwayland.enable = lib.mkDefault true;
    plugins = [
      # inputs.hyprfocus.packages.${pkgs.system}.default
    ];
  };
  wayland.windowManager.hyprland.extraConfig = ''
    general {
        # See https://wiki.hyprland.org/Configuring/Variables/ for more

        gaps_in = 5
        gaps_out = 16
        border_size = 4

        layout = dwindle
    }

    # See https://wiki.hyprland.org/Configuring/Keywords/ for more

    # Source a file (multi-file configs)
    # source = ~/.config/hypr/myColors.conf

    # unscale XWayland
    xwayland {
        force_zero_scaling = true
    }

    dwindle {
        # See https://wiki.hyprland.org/Configuring/Dwindle-Layout/ for more
        pseudotile = yes # master switch for pseudotiling. Enabling is bound to mainMod + P in the keybinds section below
        preserve_split = yes # you probably want this
    }

    master {
        # See https://wiki.hyprland.org/Configuring/Master-Layout/ for more
        new_is_master = true
    }

    gestures {
        # See https://wiki.hyprland.org/Configuring/Variables/ for more
        workspace_swipe = on
    }

    misc {
        enable_swallow = true
        swallow_regex = ^(Alacritty)$
    }

    # Example per-device config
    # See https://wiki.hyprland.org/Configuring/Keywords/#executing for more
    device:epic-mouse-v1 {
        sensitivity = -0.5
    }
  '';
}
