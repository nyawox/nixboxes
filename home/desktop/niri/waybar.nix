{
  pkgs,
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.modules.desktop.waybar;
  focusedwindow = pkgs.writeShellScript "focusedwindow" ''
    niri msg focused-window | grep Title | sed "s# Title: \"\(.*\)\"#\1#"
  '';
  # The workspace module code is based on https://github.com/hallettj/home.nix/blob/main/home-manager/features/niri/waybar.nix,
  # distributed under the Apache License 2.0 (http://www.apache.org/licenses/LICENSE-2.0).
  jq-filter = ''
    {
      text: map(if .is_active then "  " else "  " end) | join(""),
      alt: .[] | select(.is_active) | (.name // .idx),
      class: ["workspaces"]
    }
  '';
  workspaces-script = pkgs.writeShellScript "workspaces" ''
    ${pkgs.niri}/bin/niri msg --json workspaces | ${pkgs.jq}/bin/jq --unbuffered --compact-output '${jq-filter}'
  '';
in {
  options = {
    modules.desktop.waybar = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };
  config = mkIf cfg.enable {
    programs.waybar = {
      enable = true;
      systemd = {
        enable = true;
        target = "niri.service";
      };
    };
    xdg.configFile."waybar/style.css".source = ./waybar-style.css;
    xdg.configFile."waybar/config".text =
      /*
      json
      */
      ''
        {
            "layer": "top", // Waybar at top layer
            "position": "top", // Waybar position (top|bottom|left|right)
            "height": 46, // Waybar height (to be removed for auto height)
            // "width": 1280, // Waybar width
            "spacing": 5, // Gaps between modules (4px)
            // Choose the order of the modules
            // "margin-left":25,
            // "margin-right":25,
            "margin-bottom":-11,
            //"margin-top":5,
            "modules-left": ["custom/workspaces-text"],
            "modules-center": ["custom/window"],
            "modules-right": ["tray","cpu","memory","battery","pulseaudio","clock"],
            // Modules configuration

            "custom/workspaces-ind": {
              "exec": "${workspaces-script}",
              "interval": 1,
              "return-type": "json",
              "tooltip": false
            },

            "custom/window": {
              "exec": "${focusedwindow}",
              "interval": 1,
              "format": " {}",
              "separate-outputs": true,
              "max-length": 90
            },

            "wlr/taskbar": {
              "format": "{icon}",
              "tooltip-format": "{title} | {app_id}",
              "icon-theme": "WhiteSur-dark",
              "icon-size": 23,
              "on-click": "activate",
              "on-click-middle": "close",
              "on-click-right": "fullscreen",
              // "format-icons":{
              //     "10":"10"
              // }
            },

            "tray": {
                "icon-size": 20,
                "spacing": 10
            },

            "clock": {
                "tooltip-format": "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>",
                "interval": 60,
                "format": " {:%H:%M}",
                "max-length": 25
            },
            "cpu": {
                "interval":1,
                "format": "{icon0} {icon1} {icon2} {icon3}",
                "format-icons": ["▁", "▂", "▃", "▄", "▅", "▆", "▇", "█"]
            },
            "memory": {
                "interval":10,
                "format": " {used:.2f}/{total:.2f}GiB"
            },
            "battery": {
                "interval":1,
                "states": {
                    "warning": 50,
                    "critical": 20
                },
                "format": "{icon} ",
                "format-charging": "{icon}  ",
                "format-plugged": "",
                // "format-good": "",
                // "format-full": "",
                "format-icons": ["", "", "", "", ""]
            },
            "pulseaudio": {
                "scroll-step": 1,
                "format": "{icon} {volume}%",
                "format-bluetooth": "{icon} {volume}%  {format_source}",
                "format-bluetooth-muted": "  {format_source}",
                "format-muted": " {format_source}",
                "format-icons": {
                    "headphone": "󰋋",
                    "hands-free": "󰋋",
                    "headset": "",
                    "phone": "",
                    "portable": "",
                    "car": "",
                    "default": ["", "", ""]
                },
                "on-click": "pavucontrol"
            },
        }
      '';
  };
}
