{
  pkgs,
  lib,
  config,
  osConfig,
  username,
  ...
}:
with lib;
let
  cfg = config.modules.desktop.niri;
  binds =
    {
      suffixes,
      prefixes,
      substitutions ? { },
    }:
    let
      replacer = replaceStrings (attrNames substitutions) (attrValues substitutions);
      format =
        prefix: suffix:
        let
          actual-suffix =
            if isList suffix.action then
              {
                action = head suffix.action;
                args = tail suffix.action;
              }
            else
              {
                inherit (suffix) action;
                args = [ ];
              };

          action = replacer "${prefix.action}-${actual-suffix.action}";
        in
        {
          name = "${prefix.key}+${suffix.key}";
          value.action.${action} = actual-suffix.args;
        };
      pairs =
        attrs: fn:
        concatMap (
          key:
          fn {
            inherit key;
            action = attrs.${key};
          }
        ) (attrNames attrs);
    in
    listToAttrs (pairs prefixes (prefix: pairs suffixes (suffix: [ (format prefix suffix) ])));
  configure-gtk = pkgs.writeTextFile {
    name = "configure-gtk";
    destination = "/bin/configure-gtk";
    executable = true;
    text =
      let
        schema = pkgs.gsettings-desktop-schemas;
        datadir = "${schema}/share/gsettings-schemas/${schema.name}";
      in
      ''
        export XDG_DATA_DIRS=${datadir}:$XDG_DATA_DIRS
        gnome_schema=org.gnome.desktop.interface
        gsettings set $gnome_schema icon-theme 'WhiteSur-dark'
        gsettings set $gnome_schema cursor-theme 'catppuccin-mocha-pink-cursors'
        gsettings set $gnome_schema font-name 'Poppins 9'
        gsettings set $gnome_schema color-scheme prefer-dark
      '';
  };
in
{
  options = {
    modules.desktop.niri = {
      enable = mkOption {
        type = types.bool;
        default = if osConfig.modules.desktop.niri.enable then true else false;
      };
    };
  };
  config = mkIf cfg.enable {
    modules.desktop = {
      swayidle.enable = true;
      swaync.enable = true;
      waybar.enable = true;
      fuzzel.enable = true;
      xwayland.enable = true;
    };
    home.packages = with pkgs; [
      qt5.qtwayland
      qt6.qtwayland
      qt6ct
      xdg-user-dirs
      pamixer
    ];
    programs.niri.settings = {
      cursor = {
        theme = "catppuccin-mocha-pink-cursors";
        size = 24;
      };
      input = {
        keyboard.xkb.layout = "us";
        focus-follows-mouse = {
          enable = true;
          max-scroll-amount = "0%";
        };
        warp-mouse-to-focus = true;
        mouse.accel-speed = 0.0;
        touchpad = {
          tap = true;
          dwt = true;
          accel-profile = "adaptive";
          accel-speed = 0.0;
          click-method = "clickfinger";
          natural-scroll = true;
          scroll-method = "two-finger";
        };
      };
      layout = {
        gaps = 14;
        struts.left = 10;
        struts.right = 10;
        border.enable = false;
        focus-ring = {
          enable = true;
          active.color = "rgb(243 139 168)";
          inactive.color = "rgb(24 24 37)";
        };
      };
      animations =
        let
          butter = {
            spring = {
              damping-ratio = 0.75;
              epsilon = 1.0e-4;
              stiffness = 400;
            };
          };
          smooth = {
            spring = {
              damping-ratio = 0.58;
              epsilon = 1.0e-4;
              stiffness = 735;
            };
          };
        in
        {
          slowdown = 2.5;
          horizontal-view-movement = butter;
          window-movement = butter;
          workspace-switch = butter;
          window-open = smooth;
          window-close = smooth;
          screenshot-ui-open = smooth;
        };
      window-rules = [
        {
          # rounded corners
          geometry-corner-radius = {
            bottom-left = 18.0;
            bottom-right = 18.0;
            top-left = 18.0;
            top-right = 18.0;
          };
          clip-to-geometry = true;
        }
        {
          matches = singleton {
            app-id = "foot";
          };
          min-width = 400;
        }
        {
          matches = [
            { app-id = "firefox"; }
            { app-id = "vesktop"; }
            { app-id = "org.gnome.Nautilus"; }
            { app-id = "org.telegram.desktop"; }
            { app-id = "xdg-desktop-portal-gtk"; }
            { app-id = "gpu-screen-recorder-gtk"; }
            { app-id = "uget-gtk"; }
            { app-id = "pavucontrol"; }
            { app-id = "lutris"; }
            { app-id = ".blueman-manager-wrapped"; }
            { app-id = "obsidian"; }
            # {title = "beta.music.apple.com";}
          ];
          excludes = singleton {
            app-id = "org.telegram.desktop";
            title = "Media viewer";
          };
          opacity = 0.93;
          draw-border-with-background = false;
        }
      ];
      environment = {
        # fcitx
        INPUT_METHOD = "fcitx5";
        IMSETTINGS_MODULE = "fcitx5";
        XMODIFIERS = "@im=fcitx";
        GTK_IM_MODULE = "fcitx";
        QT_IM_MODULE = "fcitx";
        # force wayland
        QT_QPA_PLATFORM = "wayland;xcb";
        QT_WAYLAND_DISABLE_WINDOWDECORATION = "1"; # Disables window decorations on Qt applications
        GDK_BACKEND = "wayland,x11";
        GTK_THEME = config.gtk.theme.name;
      };
      prefer-no-csd = true;
      hotkey-overlay.skip-at-startup = true;
      screenshot-path = "/home/${username}/Pictures/screenshot-%Y-%m-%d-%H-%M-%S.png";
      spawn-at-startup = [
        { command = [ "${configure-gtk}/bin/configure-gtk" ]; }
        {
          command = [
            "${pkgs.pulseaudio}/bin/paplay"
            "/home/${username}/sounds/logon.wav"
          ];
        }
        {
          command = [
            "${getExe pkgs.swaybg}"
            "-m"
            "tile"
            "-i"
            "/home/${username}/.wallpaper.png"
          ];
        }
        { command = [ "${getExe pkgs.swaynotificationcenter}" ]; }
        { command = [ "${getExe pkgs.waybar}" ]; }
        # Only fcitx5 installed via the NixOS module contains mozc, it must be in the PATH.
        {
          command = [
            "fcitx5"
            "-r"
            "-d"
          ];
        } # -r replaces current instance
      ];
      outputs = {
        "DP-4" = {
          scale = 0.75;
          position.x = 0;
          position.y = 0;
        };
        "DP-7" = {
          scale = 0.75;
          position.x = 2560;
          position.y = 0;
        };
        "eDP-1".scale = 0.75;
      };
      binds =
        with config.lib.niri.actions;
        let
          sh = spawn "sh" "-c";
        in
        lib.attrsets.mergeAttrsList [
          {
            "Mod+E".action = spawn "${getExe pkgs.foot}";
            "Mod+I".action = spawn "${getExe pkgs.fuzzel}";
            "Mod+A".action = sh "${getExe pkgs.nautilus} --new-window";
            "Mod+Y".action = sh "${getExe pkgs.swaynotificationcenter}-client -t -sw";
            "Mod+W".action = sh "killall .waybar-wrapped && waybar";
            "Mod+Escape".action = sh "${getExe pkgs.swaylock-effects} --screenshots --clock --indicator --indicator-radius 100 --indicator-thickness 7 --effect-blur 7x5 --effect-vignette 0.5:0.5 --ring-color f5c2e7 --text-color cdd6f4 --key-hl-color fab387 --line-color 00000000 --inside-color 1e1e2e88 --separator-color 00000000 --grace 2 --fade-in 0.2";

            "XF86AudioRaiseVolume".action = sh "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1+";
            "XF86AudioLowerVolume".action = sh "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1-";
            "XF86AudioMute".action = sh "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";

            "XF86MonBrightnessUp".action = sh "brightnessctl set 10%+";
            "XF86MonBrightnessDown".action = sh "brightnessctl set 10%-";

            "Mod+Q".action = close-window;
          }
          (binds {
            suffixes = {
              "Left" = "column-left";
              "Down" = "window-or-workspace-down";
              "Up" = "window-or-workspace-up";
              "Right" = "column-right";
            };
            prefixes = {
              "Mod" = "focus";
              "Mod+Shift" = "move";
              "Mod+Ctrl" = "focus-monitor";
              "Mod+Ctrl+Shift" = "move-window-to-monitor";
            };
            substitutions = {
              "monitor-column" = "monitor";
              "monitor-window-or-workspace" = "monitor";
              "move-window-or-workspace-down" = "move-window-down-or-to-workspace-down";
              "move-window-or-workspace-up" = "move-window-up-or-to-workspace-up";
            };
          })
          (binds {
            suffixes."Home" = "first";
            suffixes."End" = "last";
            prefixes."Mod" = "focus-column";
            prefixes."Mod+Ctrl" = "move-column-to";
          })
          (binds {
            suffixes = builtins.listToAttrs (
              map (n: {
                name = toString n;
                value = [
                  "workspace"
                  n
                ];
              }) (range 1 9)
            );
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
            "Mod+WheelScrollDown" = {
              cooldown-ms = 150;
              action = focus-workspace-down;
            };
            "Mod+WheelScrollUp" = {
              cooldown-ms = 150;
              action = focus-workspace-up;
            };
            "Mod+Shift+WheelScrollDown" = {
              cooldown-ms = 150;
              action = move-column-to-workspace-down;
            };
            "Mod+Shift+WheelScrollUp" = {
              cooldown-ms = 150;
              action = move-column-to-workspace-up;
            };

            "Print".action = screenshot;
            "Shift+Print".action = screenshot-screen;

            "Mod+Shift+E".action = quit;
            "Mod+Shift+P".action = power-off-monitors;

            "Mod+Shift+Ctrl+T".action = toggle-debug-tint;
          }
        ];
    };
  };
}
