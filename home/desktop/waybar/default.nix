{
  pkgs,
  lib,
  osConfig,
  ...
}: let
  focusedwindow = pkgs.writeShellScript "focusedwindow" ''
    niri msg focused-window | grep Title | sed "s# Title: \"\(.*\)\"#\1#"
  '';
in {
  config = lib.mkIf osConfig.modules.desktop.niri.enable {
    programs.waybar = {
      enable = true;
      systemd.enable = true;
    };
    xdg.configFile."waybar/style.css".source = ./style.css;
    xdg.configFile."waybar/config".text = ''
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
          "modules-left": ["wlr/taskbar"],
          "modules-right": ["tray","cpu","memory","battery","pulseaudio","clock"],
          "modules-center": ["custom/window"],
          // Modules configuration

          "custom/window": {
            "exec": "${focusedwindow}",
            "interval": 1,
            "format": " {}",
            "separate-outputs": true,
            "on-click": "${pkgs.nwg-drawer}/bin/nwg-drawer -term foot -fm nautilus -ovl",
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
                  "headphone": "",
                  "hands-free": "",
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
