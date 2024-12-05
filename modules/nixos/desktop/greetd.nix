{
  config,
  lib,
  pkgs,
  username,
  ...
}:
with lib;
let
  cfg = config.modules.desktop.greetd;
in
{
  options = {
    modules.desktop.greetd = {
      enable = mkEnableOption "greetd";
      autoLogin = mkEnableOption "start wayland session automatically";
    };
  };
  config = mkIf cfg.enable {
    services.greetd = {
      enable = true;
      vt = 2;
      settings =
        let
          niri-session = "/run/current-system/sw/bin/niri-session"; # use the latest installed version, instead of store path, which quickly becomes outdated
        in
        {
          # auto login when /run/greetd.run don't exist
          default_session = {
            command = concatStringsSep " " [
              "${getExe pkgs.greetd.tuigreet}"
              "--cmd ${niri-session}"
              "--width 120"
              "--time"
              "--issue"
              "--remember"
              "--remember-user-session"
              "--user-menu"
              "--asterisks"
              "--theme 'border=magenta;text=blue;prompt=blue;time=blue;action=white;button=green;container=black;input=white'"
            ];
            user = "greeter";
          };
          initial_session = mkIf cfg.autoLogin {
            # oh god i kept `intial_session` typo for so long and noticed just know
            # was wondering why auto login don't work no matter what i try
            command = niri-session;
            user = "${username}";
          };
        };
    };
    security.pam.services.greetd.enableGnomeKeyring = true; # unlock gnome keyring
    environment.persistence."/persist".directories = mkIf config.modules.sysconf.impermanence.enable [
      {
        directory = "/var/cache/tuigreet";
        user = "greeter";
        group = "greeter";
        mode = "755";
      }
    ];
  };
}
