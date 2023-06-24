{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.modules.services.firetv-launcher;
in
{
  options = {
    modules.services.firetv-launcher = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
      ip = mkOption {
        type = types.str;
        default = "localcast";
      };
      launcher = mkOption {
        type = types.str;
        default = "com.spocky.projengmenu/.ui.home.MainActivity";
      };
    };
  };
  config = mkIf cfg.enable {
    systemd.services.firetv-launcher = {
      description = "Override Amazon Home Screen";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStartPre = "${pkgs.android-tools}/bin/adb connect ${cfg.ip}";
        ExecStart =
          # bash
          ''
            ${getExe pkgs.bash} -c "${pkgs.android-tools}/bin/adb -s ${cfg.ip} logcat -T 1 '*:I' | ${getExe pkgs.gnugrep} --line-buffered 'com.amazon.tv.launcher/.ui.HomeActivity_vNext' | ${pkgs.findutils}/bin/xargs -I {} ${pkgs.android-tools}/bin/adb -s ${cfg.ip} shell am start -n ${cfg.launcher}"
          '';
        Restart = "always";
        RestartSec = 5;
      };
    };
  };
}
