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
        ## Components required to complete the onboarding
        "esphome"
        "met"
        "radio_browser"
        ##
        "otp" # two factor auth
        "bluetooth" # required for switchbot
        "switchbot"
        "mobile_app"
        "broadlink"
        "accuweather"
        "ollama"
        "androidtv"
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
          pyicloud
          adb-shell
          speedtest-cli
        ];
      customComponents = [
        (
          pkgs.buildHomeAssistantComponent {
            owner = "Haoyu-UT";
            domain = "nature_remo";
            version = "1.0.5";
            src = inputs.hass-nature-remo;
          }
        )
        (
          pkgs.buildHomeAssistantComponent {
            owner = "smartHomeHub";
            domain = "smartir";
            version = "1.17.9";
            src = inputs.hass-smartir;
            # must use the same python version as buildHomeAssistantComponent
            propagatedBuildInputs = with pkgs.python312Packages; [
              aiofiles
              broadlink
            ];
            patches = [
              # Fix distutils error
              # https://github.com/smartHomeHub/SmartIR/pull/1250
              (pkgs.fetchpatch {
                url = "https://github.com/smartHomeHub/SmartIR/commit/1ed8ef23a8f7b9dcae75721eeab8d5f79013b851.patch";
                hash = "sha256-IhdnTDtUa7mS+Vw/+BqfqWIKK4hbshbVgJNjfKjgAvI=";
              })
            ];
            dontBuild = true;
            # install device codes
            postInstall = ''
              cp -r codes $out/custom_components/smartir/
            '';
          }
        )
        (
          pkgs.buildHomeAssistantComponent {
            owner = "petretiandrea";
            domain = "tapo";
            version = "git";
            src = inputs.hass-tapo;
            propagatedBuildInputs = with pkgs.python312Packages; [
              plugp100
            ];
          }
        )
      ];
      customLovelaceModules = with pkgs.home-assistant-custom-lovelace-modules; [
        mushroom
        card-mod
        button-card
        # (
        #   pkgs.stdenv.mkDerivation rec {
        #     pname = "kiosk-mode";
        #     version = "git";
        #     src = inputs.hass-kiosk-mode;
        #     installPhase = ''
        #       mkdir -p $out
        #       cp ${pname}.js $out/${pname}.js
        #     '';
        #   }
        # )
        (
          pkgs.mkYarnPackage {
            pname = "kiosk-mode";
            version = "git";

            src = inputs.hass-kiosk-mode;

            buildPhase = ''
              runHook preBuild

              yarn build

              runHook postBuild
            '';

            installPhase = ''
              runHook preInstall
              mkdir $out
              ls -R
              install -m0644 ./deps/kiosk-mode/dist/kiosk-mode.js $out

              runHook postInstall
            '';

            doDist = false;
          }
        )
      ];
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
        frontend = {
          themes = "!include_dir_merge_named themes";
        };
        mobile_app = {};
        smartir = {};
        climate = lib.singleton {
          platform = "smartir";
          name = "Neko AC";
          device_code = 1129;
          controller_data = "remote.rm_mini";
        };
        # used by kiosk-mode to toggle header visibility on mobile
        input_boolean = {
          hide_header = {
            name = "Hide Header on Mobile";
            initial = "on";
            icon = "mdi:toggle-switch";
          };
        };
        "automation manual" = [
          {
            alias = "Automatically send signal when light select state changes";
            mode = "single";
            trigger = [
              {
                platform = "state";
                entity_id = ["select.signals_light"];
              }
            ];
            condition = [];
            action = [
              {
                service = "button.press";
                metadata = {};
                data = {};
                target = {
                  entity_id = "button.send_signal_light";
                };
              }
            ];
          }
        ];
        "automation ui" = "!include automations.yaml";
        "scene ui" = "!include scenes.yaml";
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
