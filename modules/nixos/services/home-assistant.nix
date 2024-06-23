{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
with lib; let
  cfg = config.modules.services.home-assistant;
  proxyIP = "100.64.0.2";
  catppuccin = inputs.catpuccin-home-assistant.outPath + "/themes";
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
        "bluetooth"
        "esphome"
        "otp"
        "met"
        "radio_browser"
        "switchbot"
        "mobile_app"
      ];
      extraPackages = ps:
        with ps; [
          gtts
          pyatv
          pychromecast
          psycopg2
          aiohttp-zlib-ng
          aiohttp-isal
          pyqrcode # 2fa depends
          ibeacon-ble # silence error
        ];
      customComponents = lib.singleton (
        pkgs.buildHomeAssistantComponent {
          owner = "@Haoyu-UT";
          domain = "nature_remo";
          version = "1.0.5";

          src = inputs.nature-remo;
        }
      );
      config = {
        # Includes dependencies for a basic setup
        # https://www.home-assistant.io/integrations/default_config/
        default_config = {};
        homeassistant = {
          name = "Home";
          unit_system = "metric";
        };
        recorder.db_url = "postgresql:///hass";
        http = {
          use_x_forwarded_for = true;
          trusted_proxies = [
            proxyIP
          ];
        };
        bluetooth = {};
        mobile_app = {};
        "automation ui" = "!include automations.yaml";
        "scene ui" = "!include scenes.yaml";
        frontend = {
          themes = "!include_dir_merge_named themes";
        };
      };
    };
    # multi-line yaml values
    # sops.secrets."home-assistant-secrets.yaml" = {
    #   sopsFile = ../../../secrets/home-assistant-secrets.yaml;
    #   owner = "hass";
    #   path = "/var/lib/hass/secrets.yaml";
    #   restartUnits = ["home-assistant.service"];
    # };

    # prevent home-assistant fail to load when UI automations aren't defined yet
    systemd.tmpfiles.rules = [
      "f ${config.services.home-assistant.configDir}/automations.yaml 0755 hass hass"
      "f ${config.services.home-assistant.configDir}/scenes.yaml 0755 hass hass"
      "C ${config.services.home-assistant.configDir}/themes 0755 hass hass - ${catppuccin}"
    ];
    environment.persistence."/persist".directories = mkIf config.modules.sysconf.impermanence.enable (lib.singleton {
      directory = "/var/lib/hass";
      user = "hass";
      group = "hass";
    });
  };
}
