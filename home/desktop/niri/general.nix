{
  pkgs,
  config,
  lib,
  username,
  ...
}:
with lib; let
  binds = {
    suffixes,
    prefixes,
    substitutions ? {},
  }: let
    replacer = replaceStrings (attrNames substitutions) (attrValues substitutions);
    format = prefix: suffix: let
      actual-suffix =
        if isList suffix.action
        then {
          action = head suffix.action;
          args = tail suffix.action;
        }
        else {
          inherit (suffix) action;
          args = [];
        };

      action = replacer "${prefix.action}-${actual-suffix.action}";
    in {
      name = "${prefix.key}+${suffix.key}";
      value.action.${action} = actual-suffix.args;
    };
    pairs = attrs: fn:
      concatMap (key:
        fn {
          inherit key;
          action = attrs.${key};
        }) (attrNames attrs);
  in
    listToAttrs (pairs prefixes (prefix: pairs suffixes (suffix: [(format prefix suffix)])));
  configure-gtk = pkgs.writeTextFile {
    name = "configure-gtk";
    destination = "/bin/configure-gtk";
    executable = true;
    text = let
      schema = pkgs.gsettings-desktop-schemas;
      datadir = "${schema}/share/gsettings-schemas/${schema.name}";
    in ''
      export XDG_DATA_DIRS=${datadir}:$XDG_DATA_DIRS
      gnome_schema=org.gnome.desktop.interface
      gsettings set $gnome_schema icon-theme 'WhiteSur-dark'
      gsettings set $gnome_schema cursor-theme 'Catppuccin-Mocha-Pink-Cursors'
      gsettings set $gnome_schema font-name 'IBM Plex Sans 9'
      gsettings set $gnome_schema color-scheme prefer-dark
    '';
  };
in {
  home.packages = with pkgs; [
    qt5.qtwayland
    qt6.qtwayland
    qt6ct
    xdg-user-dirs
    pamixer
    wl-clipboard
    wayland-utils
    gamescope
    cage
    swaybg
  ];
  programs.niri.settings = {
    input = {
      keyboard.xkb.layout = "us";
      mouse.accel-speed = 1.0;
      touchpad = {
        tap = true;
        dwt = true;
        natural-scroll = true;
      };
    };
    # no support for rounded corners
    layout = {
      gaps = 10;
      struts.left = 10;
      struts.right = 10;
      border.enable = false;
      focus-ring.enable = true;
      focus-ring.active.color = "rgb(245 194 231)";
      focus-ring.inactive.color = "rgb(24 24 37)";
    };
    animations = let
      butter = {
        spring = {
          damping-ratio = 0.75;
          epsilon = 0.00010;
          stiffness = 400;
        };
      };
      smooth = {
        spring = {
          damping-ratio = 0.58;
          epsilon = 0.00010;
          stiffness = 735;
        };
      };
    in {
      slowdown = 2.5;
      horizontal-view-movement = butter;
      window-movement = butter;
      workspace-switch = butter;
      window-open = smooth;
      window-close = smooth;
    };
    prefer-no-csd = true;
    window-rules = [
      {
        matches = [
          {
            app-id = "foot";
          }
        ];
        min-width = 400;
      }
      # note that blur isn't supported yet
      {
        matches = [
          {app-id = "firefox";}
          {app-id = "vesktop";}
          {app-id = "org.gnome.Nautilus";}
          {app-id = "org.telegram.desktop";}
          {app-id = "Cider";}
        ];
        opacity = 0.9;
        draw-border-with-background = false;
      }
    ];
    environment = {
      # fcitx
      INPUT_METHOD = "fcitx5";
      IMSETTINGS_MODULE = "fcitx5";
      # fix electron
      NIXOS_OZONE_WL = "1";
      # force wayland
      QT_QPA_PLATFORM = "wayland";
    };
    screenshot-path = "/home/${username}/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png";
    spawn-at-startup = [
      {command = ["${configure-gtk}/bin/configure-gtk"];}
      {command = ["${pkgs.pulseaudio}/bin/paplay" "/home/${username}/sounds/logon.wav"];}
      {command = ["${pkgs.swaybg}/bin/swaybg" "-i" "/home/${username}/.wallpaper.jpg"];}
      {command = ["/usr/bin/env fish -c fcitx5"];}
      {command = ["${pkgs.swaynotificationcenter}/bin/swaync"];}
    ];
    # Currently no support for fractional scaling
    # outputs = {
    #   "HDMI-A-1".scale = 0.75;
    # };
    binds = with config.lib.niri.actions; let
      sh = spawn "sh" "-c";
    in
      lib.attrsets.mergeAttrsList [
        {
          "Mod+E".action = spawn "${pkgs.foot}/bin/foot";
          "Mod+A".action = spawn "${pkgs.fuzzel}/bin/fuzzel";
          "Mod+L".action = sh "${pkgs.gnome.nautilus}/bin/nautilus --new-window";
          "Mod+I".action = sh "${pkgs.swaynotificationcenter}/bin/swaync-client -t -sw";
          "Mod+W".action = sh "systemctl --user restart waybar.service";
          "Mod+Alt+X".action = sh "${pkgs.swaylock-effects}/bin/swaylock --screenshots --clock --indicator --indicator-radius 100 --indicator-thickness 7 --effect-blur 7x5 --effect-vignette 0.5:0.5 --ring-color f5c2e7 --text-color cdd6f4 --key-hl-color fab387 --line-color 00000000 --inside-color 1e1e2e88 --separator-color 00000000 --grace 2 --fade-in 0.2";

          "XF86AudioRaiseVolume".action = sh "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1+";
          "XF86AudioLowerVolume".action = sh "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1-";
          "XF86AudioMute".action = sh "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";

          "XF86MonBrightnessUp".action = sh "brightnessctl set 10%+";
          "XF86MonBrightnessDown".action = sh "brightnessctl set 10%-";

          "Alt+F4".action = close-window;
        }
        (binds {
          suffixes = {
            "Left" = "column-left";
            "Down" = "window-down";
            "Up" = "window-up";
            "Right" = "column-right";
          };
          prefixes = {
            "Mod" = "focus";
            "Mod+Ctrl" = "move";
            "Mod+Shift" = "focus-monitor";
            "Mod+Shift+Ctrl" = "move-window-to-monitor";
          };
          substitutions."monitor-column" = "monitor";
          substitutions."monitor-window" = "monitor";
        })
        (binds {
          suffixes."Home" = "first";
          suffixes."End" = "last";
          prefixes."Mod" = "focus-column";
          prefixes."Mod+Ctrl" = "move-column-to";
        })
        (binds {
          suffixes = {
            "U" = "workspace-down";
            "O" = "workspace-up";
          };
          prefixes = {
            "Mod" = "focus";
            "Mod+Ctrl" = "move-window-to";
            "Mod+Shift" = "move";
          };
        })
        (binds {
          suffixes = builtins.listToAttrs (map (n: {
            name = toString n;
            value = ["workspace" n];
          }) (range 1 9));
          prefixes = {
            "Mod" = "focus";
            "Mod+Ctrl" = "move-window-to";
          };
        })
        {
          "Mod+Comma".action = consume-window-into-column;
          "Mod+Period".action = expel-window-from-column;

          "Mod+R".action = switch-preset-column-width;
          "Mod+F".action = maximize-column;
          "Mod+Shift+F".action = fullscreen-window;
          "Mod+C".action = center-column;

          "Mod+Minus".action = set-column-width "-10%";
          "Mod+Kp_Add".action = set-column-width "+10%";
          "Mod+Shift+Minus".action = set-window-height "-10%";
          "Mod+Shift+Kp_Add".action = set-window-height "+10%";

          "Print".action = screenshot;
          "Shift+Print".action = screenshot-screen;

          "Mod+Shift+E".action = quit;
          "Mod+Shift+P".action = power-off-monitors;

          "Mod+Shift+Ctrl+T".action = toggle-debug-tint;
        }
      ];
  };
}
