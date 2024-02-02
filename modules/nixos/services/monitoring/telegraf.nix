{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.services.monitoring.telegraf;
in {
  options = {
    modules.services.monitoring.telegraf = {
      enable = mkOption {
        type = types.bool;
        default =
          if config.modules.services.monitoring.enable
          then true
          else false;
      };
    };
  };
  config = mkIf cfg.enable {
    services.telegraf.extraConfig = {
      agent = {
        interval = lib.mkForce "10s";
        round_interval = true;
      };
      inputs = {
        cpu = {
          percpu = true;
          totalcpu = true;
          report_active = true;
        };
        disk.mount_points = ["/" "/persist" "/mnt/hdd"];
        docker.total = true;
        io.name_templates = ["$ID_FS_LABEL" "$DM_VG_NAME/$DM_LV_NAME"];
        kernel = {};
        linux_sysctl_fs = {};
        net = {};
        netstat = {};
        processes = {};
      };
      outputs = {
        influxdb = {
          urls = ["http://nixpro64.nyaa.nixhome.shop:8234"];
          database = "telegraf_metrics";
        };
      };
    };
  };
}
