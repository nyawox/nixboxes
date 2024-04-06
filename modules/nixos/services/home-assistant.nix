{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.modules.services.home-assistant;
in {
  options = {
    modules.services.home-assistant = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };
  config = mkIf cfg.enable {
    services.home-assistant = {
      enable = true;
      extraComponents = [
        "esphome"
        "met"
        "radio_browser"
      ];
      extraPackages = ps:
        with ps; [
          (callPackage hass-dependencies/plugp100.nix {})
          gtts
          pyatv
          pychromecast
          psycopg2
        ];
      customComponents = with pkgs.home-assistant-custom-components; [
        # (pkgs.callPackage hass-components/tapo.nix {})
        # (pkgs.callPackage hass-components/nature-remo.nix {})
        # (pkgs.callPackage hass-components/alexa-media-player.nix {})
      ];
      config = {
        # Includes dependencies for a basic setup
        # https://www.home-assistant.io/integrations/default_config/
        default_config = {};
        recorder.db_url = "postgresql:///hass";
      };
    };
    # multi-line yaml values
    # sops.secrets."home-assistant-secrets.yaml" = {
    #   sopsFile = ../../../secrets/home-assistant-secrets.yaml;
    #   owner = "hass";
    #   path = "/var/lib/hass/secrets.yaml";
    #   restartUnits = ["home-assistant.service"];
    # };
    environment.persistence."/persist".directories = mkIf config.modules.sysconf.impermanence.enable [
      {
        directory = "/var/lib/hass";
        user = "hass";
        group = "hass";
      }
    ];
  };
}
