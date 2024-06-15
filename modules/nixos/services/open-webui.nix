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
    };
  };
  config = mkIf cfg.enable {
    services.open-webui = {
      enable = true;
      host = "0.0.0.0";
      port = 11454;
      openFirewall = false;
      environment = {
        OLLAMA_API_BASE_URL = "http://lolcathost.nyaa.nixlap.top:11451";
        ANONYMIZED_TELEMETRY = "False";
        DO_NOT_TRACK = "True";
        SCARF_NO_ANALYTICS = "True";
      };
    };
    environment.persistence."/persist".directories =
      lib.mkIf config.modules.sysconf.impermanence.enable
      ["/var/lib/open-webui"];
  };
}
