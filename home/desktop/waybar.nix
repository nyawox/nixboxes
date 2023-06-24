_: {
  programs.waybar = {
    enable = true;
    systemd.enable = false;
    # systemd.target = "graphical-session.target";
  };
  xdg.configFile."waybar/config".text = ''
    {
        "layer": "top", // Waybar at top layer
        "position": "top", // Waybar position (top|bottom|left|right)
        "height": 50, // Waybar height (to be removed for auto height)
        // "width": 1280, // Waybar width
        "spacing": 5, // Gaps between modules (4px)
        // Choose the order of the modules
        // "margin-left":25,
        // "margin-right":25,
        "margin-bottom":-11,
        //"margin-top":5,
        "modules-left": ["hyprland/workspaces"],
        "modules-right": ["tray","memory","battery","cpu","pulseaudio","clock"],
        "modules-center": ["hyprland/window"],
        // Modules configuration


        "hyprland/window": {
          "format": " {}",
          "separate-outputs": true,
          "on-click": "wofi -H 1200 -S drun -I"
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
            "icon-size": 21,
            "spacing": 10
        },

        "clock": {
            "tooltip-format": "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>",
            "interval": 60,
            "format": "{:%H:%M}",
            "max-length": 25
        },
        "cpu": {
            "interval":1,
            "format": "{icon0} {icon1} {icon2} {icon3}",
            "format-icons": ["▁", "▂", "▃", "▄", "▅", "▆", "▇", "█"]
        },
        "memory": {
            "interval":10,
            "format": "{used:.2f}/{total:.2f}GiB "
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
            "format": "{volume}% {icon}",
            "format-bluetooth": "{volume}% {icon} {format_source}",
            "format-bluetooth-muted": " {icon} {format_source}",
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
  xdg.configFile."waybar/style.css".text = ''
    * {
        font-family: BlexMono Nerd Font,FontAwesome, Roboto, Arial, sans-serif;
        font-size: 14px;
    }

    window#waybar {
        background-color: transparent;
    }

    #workspaces{
        background-color: transparent;
        margin-top: 10px;
        margin-bottom: 10px;
        margin-right: 10px;
        margin-left: 25px;
    }
    #workspaces button{
        box-shadow: rgba(0, 0, 0, 0.116) 2 2 5 2px;
        background-color: #fff ;
        border-radius: 15px;
        margin-right: 10px;
        padding-top: 4px;
        padding-bottom: 2px;
        padding-right: 10px;
        font-size: 15px;
        color: 	#cba6f7 ;
    }

    #workspaces button.active{
        padding-right: 20px;
        box-shadow: rgba(0, 0, 0, 0.288) 2 2 5 2px;
        text-shadow: 0 0 5px rgba(0, 0, 0, 0.377);
        padding-left: 20px;
        padding-bottom: 3px;
        background: rgb(202,158,230);
        background: linear-gradient(45deg, rgba(202,158,230,1) 0%, rgba(245,194,231,1) 43%, rgba(180,190,254,1) 80%, rgba(137,180,250,1) 100%);
        background-size: 300% 300%;
        animation: gradient 10s ease infinite;
        color: #fff;
    }

    @keyframes gradient {
    	0% {
    		background-position: 0% 50%;
    	}
    	50% {
    		background-position: 100% 50%;
    	}
    	100% {
    		background-position: 0% 50%;
    	}
    }


    #clock,
    #cpu,
    #memory,
    #battery,
    #pulseaudio,
    #tray,
    #window {
        padding: 0 10px;
        border-radius: 15px;
        background-color: #cdd6f4;
        color: #516079;
        box-shadow: rgba(0, 0, 0, 0.116) 2 2 5 2px;
        margin-top: 10px;
        margin-bottom: 10px;
        margin-right: 10px;
    }

    #window{
        background: rgb(166,209,137);
        background: linear-gradient(52deg, rgba(166,209,137,1) 0%, rgba(166,227,161,1) 26%, rgba(148,226,213,1) 65%, rgba(129,200,190,1) 100%);
        background-size: 300% 300%;
        animation: gradient 15s ease infinite;
        text-shadow: 0 0 5px rgba(0, 0, 0, 0.377);
        font-weight: bolder;
        font-size: 15px;
        color: #fff;
    }

    #clock {
        background: rgb(245,194,231);
        background: linear-gradient(45deg, rgba(245,194,231,1) 0%, rgba(203,166,247,1) 64%, rgba(202,158,230,1) 100%);
        margin-right: 25px;
        color: #fff ;
        background-size: 300% 300%;
        text-shadow: 0 0 5px rgba(0, 0, 0, 0.377);
        animation: gradient 20s ease infinite;
        font-size: 15px;
        padding-top: 5px;
        padding-bottom: 5px;
        padding-left: 20px;
        padding-right: 20px;
        font-weight: bolder;
    }

    #battery {
        background-color: #fff;
        color:#a6e3a1;
        font-weight: bolder;
        font-size: 20px;
        padding-left: 15px;
        padding-right: 15px;
    }

    #battery.charging, #battery.plugged {
        background-color:#a6e3a1;
        color: #fff ;
    }

    @keyframes blink {
        to {
            background-color: #f9e2af;
            color:#96804e;
        }
    }

    label:focus {

    }

    #cpu {
        background: rgb(137,220,235);
        background: linear-gradient(52deg, rgba(137,220,235,1) 0%, rgba(116,199,236,1) 32%, rgba(137,180,250,1) 72%, rgba(180,190,254,1) 100%);
        background-size: 300% 300%;
        animation: gradient 20s ease infinite;
        text-shadow: 0 0 5px rgba(0, 0, 0, 0.377);
        /* background-color: #b4befe; */
        color: 	#fff;
    }

    #memory {
        background-color: #eba0ac;
        color: 	#fff;
        font-size: 15px;
        padding-top: 5px;
        padding-bottom: 5px;
        padding-left: 20px;
        padding-right: 20px;
        font-weight: bolder;
    }


    #pulseaudio {
        background-color:  	#fab387;
        color: #fff;
        font-size: 15px;
        padding-top: 5px;
        padding-bottom: 5px;
        padding-left: 20px;
        padding-right: 20px;
        font-weight: bolder;
    }

    #pulseaudio.muted {
        background-color: #90b1b1;
        padding-top: 5px;
        padding-bottom: 5px;
        padding-left: 20px;
        padding-right: 20px;
        font-weight: bolder;
    }

    #tray {
        background-color: #f9e2af;
    }

    #tray > .passive {
        -gtk-icon-effect: dim;
    }

    #tray > .needs-attention {
        -gtk-icon-effect: highlight;
        background-color: #eb4d4b;
    }

  '';
}
