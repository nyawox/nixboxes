{pkgs, ...}: {
  programs.waybar = {
    enable = true;
    systemd.enable = false;
    # systemd.target = "graphical-session.target";
  };
  xdg.configFile."waybar/style.css".source = ./style.css;
  xdg.configFile."waybar/config".text = ''
    {
        "layer": "top", // Waybar at top layer
        "position": "top", // Waybar position (top|bottom|left|right)
        "height": 40, // Waybar height (to be removed for auto height)
        // "width": 1280, // Waybar width
        "spacing": 5, // Gaps between modules (4px)
        // Choose the order of the modules
        // "margin-left":25,
        // "margin-right":25,
        "margin-bottom":-11,
        //"margin-top":5,
        "modules-left": ["hyprland/workspaces"],
        "modules-right": ["tray","cpu","memory","battery","pulseaudio","clock"],
        "modules-center": ["hyprland/window"],
        // Modules configuration


        "hyprland/window": {
          "format": " {}",
          "separate-outputs": true,
          "on-click": "${pkgs.nwg-drawer}/bin/nwg-drawer -term wezterm -fm nautilus -ovl",
          "max-length": 90
        },

        "hyprland/workspaces": {
            "format": "{id}",
            "format-active": " {id} ",
            "on-click": "activate"
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
}
