{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
with lib; let
  cfg = config.modules.services.home-assistant;
  proxyIP = "100.64.0.1";
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
        climate = singleton {
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
        ios.actions = [
          {
            name = "Lock Front Door";
            label.text = "Lock front door";
            icon = {
              icon = "door_closed_lock";
              color = "#ffffff";
            };
            show_in_carplay = false;
            show_in_watch = true;
          }
          {
            name = "Unlock Front Door";
            label.text = "Unlock front door";
            icon = {
              icon = "door_open";
              color = "#ffffff";
            };
            show_in_carplay = false;
            show_in_watch = true;
          }
          {
            name = "Meow: Nightlight";
            label.text = "Night";
            icon = {
              icon = "weather_night";
              color = "#ffffff";
            };
            show_in_carplay = false;
            show_in_watch = true;
          }
          {
            name = "Meow: Daylight";
            label.text = "Day";
            icon = {
              icon = "lightbulb_on";
              color = "#ffffff";
            };
            show_in_carplay = false;
            show_in_watch = true;
          }
          {
            name = "Meow: Turn Off Light";
            label.text = "Off";
            icon = {
              icon = "lightbulb_off";
              color = "#ffffff";
            };
            show_in_carplay = false;
            show_in_watch = true;
          }
          {
            name = "Meow: 60 sec timer";
            label.text = "Turn off after 60 sec";
            icon = {
              icon = "timer_settings";
              color = "#ffffff";
            };
            show_in_carplay = false;
            show_in_watch = true;
          }
          {
            name = "Meow AC: Instant Cooling";
            label.text = "Instant Cooling";
            icon = {
              icon = "snowflake";
              color = "#ffffff";
            };
            show_in_carplay = false;
            show_in_watch = true;
          }
        ];
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
          {
            alias = "Lock Front Door";
            trigger = {
              platform = "event";
              event_type = "ios.action_fired";
              event_data = {
                actionName = "Lock Front Door";
              };
            };
            action = [
              {
                device_id = "d1bc02d79eb3af192fdb98799e160ddb";
                domain = "lock";
                entity_id = "c537fbbb20ffca87a458354ff063b961";
                type = "lock";
              }
              {
                device_id = "37b4107bf9588392012d15546937342d";
                domain = "mobile_app";
                type = "notify";
                message = "Front door has been locked";
              }
            ];
          }
          {
            alias = "Unlock Front Door";
            trigger = {
              platform = "event";
              event_type = "ios.action_fired";
              event_data = {
                actionName = "Unlock Front Door";
              };
            };
            action = [
              {
                device_id = "d1bc02d79eb3af192fdb98799e160ddb";
                domain = "lock";
                entity_id = "c537fbbb20ffca87a458354ff063b961";
                type = "unlock";
              }
              {
                device_id = "37b4107bf9588392012d15546937342d";
                domain = "mobile_app";
                type = "notify";
                message = "Front door has been unlocked";
                data = {
                  sound = "US-EN-Alexa-Front-Door-Unlocked.wav";
                };
              }
            ];
          }
          {
            alias = "Nightlight";
            trigger = [
              {
                event_type = "ios.action_fired";
                event_data = {
                  actionName = "Meow: Nightlight";
                };
                platform = "event";
              }
            ];
            action = [
              {
                service = "select.select_option";
                metadata = {};
                data = {
                  option = "1. On";
                };
                target = {
                  entity_id = "select.signals_light";
                };
                enabled = true;
              }
              {
                service = "button.press";
                metadata = {};
                data = {};
                target = {
                  entity_id = "button.send_signal_light";
                };
                enabled = true;
              }
              {
                service = "select.select_option";
                metadata = {};
                data = {
                  option = "8. Night";
                };
                target = {
                  entity_id = "select.signals_light";
                };
              }
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
          {
            alias = "Daylight";
            trigger = [
              {
                event_data = {
                  actionName = "Meow: Daylight";
                };
                event_type = "ios.action_fired";
                platform = "event";
              }
            ];
            action = [
              {
                service = "select.select_option";
                metadata = {};
                data = {
                  option = "1. On";
                };
                target = {
                  entity_id = "select.signals_light";
                };
                enabled = true;
              }
              {
                service = "button.press";
                metadata = {};
                data = {};
                target = {
                  entity_id = "button.send_signal_light";
                };
                enabled = true;
              }
              {
                service = "select.select_option";
                metadata = {};
                data = {
                  option = "6. Daylight";
                };
                target = {
                  entity_id = "select.signals_light";
                };
              }
              {
                service = "button.press";
                metadata = {};
                data = {};
                target = {
                  entity_id = "button.send_signal_light";
                };
              }
              {
                service = "select.select_option";
                metadata = {};
                data = {
                  option = "5. Max";
                };
                target = {
                  entity_id = "select.signals_light";
                };
              }
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
          {
            alias = "Turn off light";
            trigger = [
              {
                event_data = {
                  actionName = "Meow: Turn Off Light";
                };
                event_type = "ios.action_fired";
                platform = "event";
              }
            ];
            action = [
              {
                service = "select.select_option";
                metadata = {};
                data = {
                  option = "2. Off";
                };
                target = {
                  entity_id = "select.signals_light";
                };
              }
            ];
          }
          {
            alias = "Turn off light after 60 seconds";
            trigger = [
              {
                event_type = "ios.action_fired";
                event_data = {
                  actionName = "Meow: 60 sec timer";
                };
                platform = "event";
              }
            ];
            action = [
              {
                service = "select.select_option";
                metadata = {};
                data = {
                  option = "10. 60Min Auto-Off";
                };
                target = {
                  entity_id = "select.signals_light";
                };
              }
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
          {
            alias = "Meow AC: Instant Cool";
            trigger = [
              {
                event_data = {
                  actionName = "Meow AC: Instant Cooling";
                };
                event_type = "ios.action_fired";
                platform = "event";
              }
            ];
            action = [
              {
                service = "climate.turn_on";
                metadata = {};
                data = {};
                target = {
                  entity_id = "climate.ac_remo_mini";
                };
              }
              {
                service = "climate.set_temperature";
                metadata = {};
                data = {
                  temperature = 16;
                  hvac_mode = "cool";
                };
                target = {
                  entity_id = "climate.ac_remo_mini";
                };
              }
              {
                service = "climate.set_swing_mode";
                metadata = {};
                data = {
                  swing_mode = "⥮5";
                };
                target = {
                  entity_id = "climate.ac_remo_mini";
                };
              }
              {
                service = "climate.set_fan_mode";
                metadata = {};
                data = {
                  fan_mode = "4";
                };
                target = {
                  entity_id = "climate.ac_remo_mini";
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
    environment.persistence."/persist".directories = mkIf config.modules.sysconf.impermanence.enable (singleton {
      directory = "/var/lib/hass";
      user = "hass";
      group = "hass";
    });
  };
}
