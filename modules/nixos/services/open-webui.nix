{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.services.open-webui;
in {
  options = {
    modules.services.open-webui = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
      port = mkOption {
        type = types.int;
        default = 11454;
      };
    };
  };
  config = mkIf cfg.enable {
    services.open-webui = {
      enable = true;
      host = "0.0.0.0";
      port = cfg.port;
      environment = {
        ENV = "prod";
        OLLAMA_BASE_URL = "http://localpost.nyaa.nixlap.top:11451";
        ANONYMIZED_TELEMETRY = "False";
        DO_NOT_TRACK = "True";
        SCARF_NO_ANALYTICS = "True";
      };
    };
    # Fix the issue that open-webui fails to use existing directory
    users = {
      groups.open-webui = {};
      users.open-webui = {
        group = "open-webui";
        isSystemUser = true;
      };
    };
    systemd.services.open-webui.serviceConfig = {
      DynamicUser = mkForce false;
      User = "open-webui";
      Group = "open-webui";
    };
    environment.persistence."/persist".directories = mkIf config.modules.sysconf.impermanence.enable (singleton {
      directory = "/var/lib/open-webui";
      user = "open-webui";
      group = "open-webui";
      mode = "750";
    });
  };
}
