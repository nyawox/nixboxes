{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.modules.services.monitoring.grafana;
in {
  options = {
    modules.services.monitoring.grafana = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };
  config = mkIf cfg.enable {
    services.grafana = {
      enable = true;
      # declarativePlugins = with pkgs.grafanaPlugins; [
      # ];
      settings = {
        server = {
          domain = "127.0.0.1";
          http_addr = "0.0.0.0";
          http_port = 3042;
          protocol = "http";
          enable_gzip = true;
        };
      };
      provision = {
        enable = true;
        datasources.settings.datasources = [
          {
            name = "Prometheus";
            type = "prometheus";
            access = "proxy";
            url = "http://127.0.0.1:${toString config.services.prometheus.port}";
          }
          {
            name = "InfluxDB";
            type = "influxdb";
            access = "proxy";
            url = "http://nixpro64.nyaa.nixhome.shop:8234";
            jsonData = {
              dbName = "telegraf_metrics";
              httpMode = "GET";
            };
          }
          {
            name = "Loki";
            type = "loki";
            access = "proxy";
            url = "http://nixpro64.nyaa.nixhome.shop:3030";
          }
        ];
        # datasources.settings.deleteDatasources = [
        #   {
        #     name = "InfluxDB_v1";
        #     orgId = 1;
        #   }
        # ];
        dashboards = {
          settings = {
            providers = [
              {
                name = "Dashboards";
                options.path = "/etc/grafana-dashboards";
              }
            ];
          };
        };
      };
    };

    environment.etc = {
      "grafana-dashboards/system-overview.json" = {
        source = pkgs.fetchurl {
          url = "https://grafana.com/api/dashboards/12224/revisions/1/download";
          sha256 = "1b1b3hkyql69fzyniqgisga3vq1majv65lbnazqybc55z3m7swsr";
        };
        group = "grafana";
        user = "grafana";
      };
      "grafana-dashboards/systemd-journal.json".source = ./grafana-dashboards/system-logs.json;
    };

    environment.persistence."/persist".directories = lib.mkIf config.modules.sysconf.impermanence.enable ["/var/lib/grafana"];
  };
}
