{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.modules.virtualisation.waydroid;
  waydroid-launch = pkgs.writeShellScript "waydroid-launch" ''
    sleep 3
    ${pkgs.waydroid}/bin/waydroid show-full-ui
  '';
  # guacamole-xml = pkgs.writeText "user-mapping.xml" ''
  #   <?xml version="1.0" encoding="UTF-8"?>
  #   <user-mapping>
  #        <authorize
  #           username="nyaa"
  #           password="9970626666560a32465d4ce10d28f3233365af833e15eed59884d9477862c379"
  #           encoding="sha256">
  #         <connection name="Android RDP">
  #             <protocol>rdp</protocol>
  #             <param name="hostname">127.0.0.1</param>
  #             <param name="port">3150</param>
  #             <param name="security">any</param>
  #             <param name="ignore-cert">true</param>
  #             <param name="color-depth">24</param>
  #             <param name="force-loseless">true</param>
  #             <param name="enable-touch">true</param>
  #         </connection>
  #         <connection name="Windows">
  #             <protocol>rdp</protocol>
  #             <param name="hostname">127.0.0.1</param>
  #             <param name="port">3389</param>
  #             <param name="security">any</param>
  #             <param name="ignore-cert">true</param>
  #             <param name="color-depth">24</param>
  #             <param name="force-loseless">true</param>
  #             <param name="enable-touch">true</param>
  #         </connection>
  #       </authorize>
  #   </user-mapping>
  # '';
in {
  options = {
    modules.virtualisation.waydroid = {
      rdp = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };
  config = mkIf cfg.rdp {
    modules.virtualisation.waydroid.enable = lib.mkForce true;
    systemd = {
      user.services.waydroid-rdp = {
        enable = true;
        description = "cloud android";
        wantedBy = ["graphical-session.target"];
        serviceConfig = {
          ExecStart = ''
            ${pkgs.weston}/bin/weston --config=/etc/waydroid-cloud.ini --shell=kiosk --backend=rdp --rdp-tls-cert=/var/lib/waydroid/waydroid-rdp.crt --rdp-tls-key=/var/lib/waydroid/waydroid-rdp.key --height=953 --width=496 --port=3150 --no-clients-resize
          '';
          Restart = "on-failure";
          RestartSec = "5s";
        };
      };
      services.waydroid-cert-renewal = {
        enable = true;
        description = "waydroid rdp cert renewal";
        script = ''
          ${pkgs.freerdp3}/bin/winpr-makecert -rdp -silent -n waydroid-rdp -path /var/lib/waydroid
        '';
        serviceConfig = {
          Type = "oneshot";
          User = "root";
        };
      };
      timers.waydroid-cert-renewal = {
        wantedBy = ["timers.target"];
        timerConfig = {
          OnCalendar = "yearly";
          Persistent = true;
          Unit = "waydroid-cert-renewal.service";
        };
      };
    };
    # modules.virtualisation.arion.enable = lib.mkForce true;
    # virtualisation.arion.projects.guacamole.settings = {
    #   project.name = "guacamole";
    #   services.guacd.service = {
    #     name = "guacd";
    #     image = "docker.io/guacamole/guacd:latest";
    #     labels."io.containers.autoupdate" = "registry";
    #   };
    #   services.guacamole.service = {
    #     image = "docker.io/guacamole/guacamole:latest";
    #     links = ["guacd"];
    #     ports = ["8080:8150"];
    #     environment = {
    #       POSTGRESQL_HOSTNAME = "nixpro64.nyaa.nixlap.top";
    #       POSTGRESQL_PORT = 5432; # Default port
    #       POSTGRESQL_DATABASE = "guacamole";
    #       POSTGRESQL_USER = "guacamole";
    #     };
    #     labels."io.containers.autoupdate" = "registry";
    #   };
    # };
    environment = {
      etc."waydroid-cloud.ini".text = lib.generators.toINI {} {
        autolaunch = {
          path = "${waydroid-launch}";
        };
        rdp = {
          refresh-rate = 120;
        };
        libinput = {
          enable-tap = true;
          tap-and-drag = true;
          natural-scroll = true;
        };
        shell = {
          panel-position = "none";
          locking = false;
        };
      };
      shellAliases = {
        droidstart = "systemctl --user start waydroid-rdp";
        droidstop = "systemctl --user stop waydroid-rdp";
        droidrestart = "systemctl --user restart waydroid-rdp";
        droidstatus = "systemctl --user status waydroid-rdp";
        droidlog = "journalctl --user -feu waydroid-rdp";
        droidlogs = "journalctl --user -xeu waydroid-rdp";
        droidrdp = "remmina -c rdp://127.0.0.1:3150";
      };
    };
  };
}
