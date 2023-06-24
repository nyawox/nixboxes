{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.services.monitoring.promtail;
in {
  options = {
    modules.services.monitoring.promtail = {
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
    services.promtail = {
      enable = true;
      configuration = {
        server = {
          http_listen_port = 3031;
          grpc_listen_port = 0;
        };
        positions = {
          filename = "/tmp/positions.yaml";
        };
        clients = [
          {
            url = "http://nixpro64.nyaa.nixhome.shop:3030/loki/api/v1/push";
          }
        ];
        scrape_configs = [
          {
            job_name = "journal";
            journal = {
              max_age = "12h";
              labels = {
                job = "systemd-journal";
                host = config.networking.hostName;
              };
            };
            relabel_configs = [
              {
                source_labels = ["__journal__systemd_unit"];
                target_label = "unit";
              }
            ];
          }
        ];
      };
    };
  };
}
