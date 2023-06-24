{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.services.monitoring.prometheus;
  telegrafport = 9273;
in {
  options = {
    modules.services.monitoring.prometheus = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };
  config = mkIf cfg.enable {
    services.prometheus = {
      enable = true;
      port = 9001;

      # ingest the published nodes
      scrapeConfigs = [
        {
          job_name = "telegraf";
          scrape_interval = "60s";
          metrics_path = "/metrics";
          static_configs = [
            {
              targets = [
                "127.0.0.1:${toString telegrafport}"
                "lolcathost.nyaa.nixhome.shop:${toString telegrafport}"
                "nixpro64.nyaa.nixhome.shop:${toString telegrafport}"
                "tomoyo.nyaa.nixhome.shop:${toString telegrafport}"
              ];
            }
          ];
        }
      ];
    };

    environment.persistence."/persist".directories = lib.mkIf config.modules.sysconf.impermanence.enable ["/var/lib/prometheus2"];
  };
}
