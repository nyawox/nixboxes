{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.services.morphic;
  ollama-url = "http://localpost.hsnet.nixlap.top:11451";
  ollama-model = "mistral-nemo:12b-instruct-2407-q4_K_S";
  ollama-sub-model = "mistral-nemo:12b-instruct-2407-q4_K_S";
in {
  options = {
    modules.services.morphic = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };
  config = mkIf cfg.enable {
    sops.secrets.morphic = {
      sopsFile = ../../../secrets/morphic.env;
      format = "dotenv";
    };
    modules.virtualisation.arion.enable = mkForce true;
    virtualisation.arion.projects.morphic.settings = {
      project.name = "morphic";
      services.morphic.service = {
        image = "shenlw/morphic:latest";
        ports = ["3000:3000"];
        network_mode = "host";
        environment = {
          OLLAMA_BASE_URL = ollama-url;
          OLLAMA_MODEL = ollama-model;
          OLLAMA_SUB_MODEL = ollama-sub-model;
        };
        env_file = [
          # required for tavily, upstash redis secrets. currently no support for local engine and redis
          config.sops.secrets.morphic.path
        ];
        restart = "unless-stopped";
        labels."io.containers.autoupdate" = "registry";
      };
    };
    systemd.services.arion-morphic = {
      wants = ["network-online.target"];
      after = ["network-online.target"];
    };
  };
}
