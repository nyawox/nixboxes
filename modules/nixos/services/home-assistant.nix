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
  catppuccin = "${inputs.catpuccin-home-assistant.outPath}/themes";

  mkIosAction = {
    name,
    label,
    icon,
    show_in_carplay ? false,
    show_in_watch ? true,
    sound ? null,
  }: {
    inherit name;
    label = {text = label;};
    icon = {
      inherit icon;
      color = "#ffffff";
    };
    inherit show_in_carplay show_in_watch;
    data = optionalAttrs (sound != null) {inherit sound;};
  };

  mkIosAutomation = {
    name,
    action,
    condition ? [],
  }: {
    alias = "${name} Automation";
    trigger = [
      {
        platform = "event";
        event_type = "ios.action_fired";
        event_data = {actionName = name;};
      }
    ];
    inherit condition action;
  };
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
          trusted_proxies = [proxyIP];
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
        input_boolean = {
          hide_header = {
            name = "Hide Header on Mobile";
            initial = "on";
            icon = "mdi:toggle-switch";
          };
        };
        ios.actions = [
          (mkIosAction {
            name = "Lock Front Door";
            label = "Lock front door";
            icon = "door_closed_lock";
          })
          (mkIosAction {
            name = "Unlock Front Door";
            label = "Unlock front door";
            icon = "door_open";
            sound = "US-EN-Alexa-Front-Door-Unlocked.wav";
          })
          (mkIosAction {
            name = "Meow: Nightlight";
            label = "Night";
            icon = "weather_night";
          })
          (mkIosAction {
            name = "Meow: Daylight";
            label = "Day";
            icon = "lightbulb_on";
          })
          (mkIosAction {
            name = "Meow: Turn Off Light";
            label = "Off";
            icon = "lightbulb_off";
          })
          (mkIosAction {
            name = "Meow: 60 sec timer";
            label = "Turn off after 60 sec";
            icon = "timer_settings";
          })
          (mkIosAction {
            name = "Meow AC: Instant Cooling";
            label = "Instant Cooling";
            icon = "snowflake";
          })
        ];
        "automation manual" = [
          {
            alias = "Automatically send signal when light select state changes";
            trigger = [
              {
                platform = "state";
                entity_id = "select.signals_light";
              }
            ];
            action = [
              {
                service = "button.press";
                target = {entity_id = "button.send_signal_light";};
              }
            ];
          }
          (mkIosAutomation {
            name = "Lock Front Door";
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
          })
          (mkIosAutomation {
            name = "Unlock Front Door";
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
              }
            ];
          })
          (mkIosAutomation {
            name = "Meow: Nightlight";
            action = [
              {
                service = "select.select_option";
                data = {option = "1. On";};
                target = {entity_id = "select.signals_light";};
              }
              {
                service = "button.press";
                target = {entity_id = "button.send_signal_light";};
              }
              {
                service = "select.select_option";
                data = {option = "8. Night";};
                target = {entity_id = "select.signals_light";};
              }
              {
                service = "button.press";
                target = {entity_id = "button.send_signal_light";};
              }
            ];
          })
          (mkIosAutomation {
            name = "Meow: Daylight";
            action = [
              {
                service = "select.select_option";
                data = {option = "1. On";};
                target = {entity_id = "select.signals_light";};
              }
              {
                service = "button.press";
                target = {entity_id = "button.send_signal_light";};
              }
              {
                service = "select.select_option";
                data = {option = "6. Daylight";};
                target = {entity_id = "select.signals_light";};
              }
              {
                service = "button.press";
                target = {entity_id = "button.send_signal_light";};
              }
              {
                service = "select.select_option";
                data = {option = "5. Max";};
                target = {entity_id = "select.signals_light";};
              }
              {
                service = "button.press";
                target = {entity_id = "button.send_signal_light";};
              }
            ];
          })
          (mkIosAutomation {
            name = "Meow: Turn Off Light";
            action = [
              {
                service = "select.select_option";
                data = {option = "2. Off";};
                target = {entity_id = "select.signals_light";};
              }
            ];
          })
        ];
        "automation ui" = "!include automations.yaml";
        "scene ui" = "!include scenes.yaml";
      };
    };
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
