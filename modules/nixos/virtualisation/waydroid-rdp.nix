# sudo waydroid init -s GAPPS -f
# systemctl --user restart waydroid-rdp
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
    ${getExe pkgs.waydroid} show-full-ui
  '';
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
    modules.virtualisation.waydroid.enable = mkForce true;
    systemd = {
      user.services.waydroid-rdp = {
        enable = true;
        description = "cloud android";
        wantedBy = ["graphical-session.target"];
        serviceConfig = {
          ExecStart = ''
            ${getExe pkgs.weston} --config=/etc/waydroid-cloud.ini --shell=kiosk --backend=rdp --rdp-tls-cert=/var/lib/waydroid/waydroid-rdp.crt --rdp-tls-key=/var/lib/waydroid/waydroid-rdp.key --height=953 --width=496 --port=3150 --no-clients-resize
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
