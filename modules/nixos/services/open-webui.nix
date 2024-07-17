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
        OPENAI_API_BASE_URL = "https://api.groq.com/openai/v1"; # Add API key manually
        ENABLE_RAG_WEB_SEARCH = "True";
        RAG_WEB_SEARCH_ENGINE = "searxng";
        SEARXNG_QUERY_URL = "http://localghost.nyaa.nixlap.top:8420/search";
        RAG_WEB_SEARCH_RESULT_COUNT = "3";
        AUDIO_STT_ENGINE = "openai";
        AUDIO_STT_OPENAI_API_BASE_URL = "https://api.groq.com/openai/v1"; # Add API key manually
        AUDIO_STT_MODEL = "whisper-large-v3";
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
