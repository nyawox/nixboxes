{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
with lib;
let
  cfg = config.modules.services.home-assistant;
  proxyIP = "100.64.0.1"; # set localghost ip
  catppuccin = "${inputs.catpuccin-home-assistant.outPath}/themes";

  mkIosAction =
    {
      name,
      label,
      icon,
      show_in_carplay ? false,
      show_in_watch ? true,
    }:
    {
      inherit name;
      label = {
        text = label;
      };
      icon = {
        inherit icon;
        color = "#ffffff";
      };
      inherit show_in_carplay show_in_watch;
    };

  mkIosAutomation =
    {
      name,
      action,
      condition ? [ ],
    }:
    {
      alias = "${name} Automation";
      trigger = [
        {
          platform = "event";
          event_type = "ios.action_fired";
          event_data = {
            actionName = name;
          };
        }
      ];
      inherit condition action;
    };
in
{
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
      extraPackages =
        ps: with ps; [
          gtts
          pyatv
          pychromecast
          psycopg2
          aiohttp-zlib-ng
          aiohttp-fast-zlib
          pyqrcode # 2fa depends
          ibeacon-ble # silence error
          adb-shell
          speedtest-cli
        ];
      customComponents = [
        (pkgs.buildHomeAssistantComponent {
          owner = "Haoyu-UT";
          domain = "nature_remo";
          version = "unstable";
          src = inputs.hass-nature-remo;
        })
        (pkgs.buildHomeAssistantComponent {
          owner = "smartHomeHub";
          domain = "smartir";
          version = "unstable";
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
        })
        (pkgs.buildHomeAssistantComponent {
          owner = "petretiandrea";
          domain = "tapo";
          version = "unstable";
          src = inputs.hass-tapo;
          propagatedBuildInputs = with pkgs.python312Packages; [
            plugp100
          ];
        })
      ];
      customLovelaceModules = with pkgs.home-assistant-custom-lovelace-modules; [
        mushroom
        card-mod
        button-card
        (pkgs.stdenv.mkDerivation rec {
          pname = "kiosk-mode";
          version = "git";

          src = inputs.hass-kiosk-mode;

          nativeBuildInputs = with pkgs; [
            nodejs
            pnpm.configHook
          ];

          pnpmDeps = pkgs.pnpm.fetchDeps {
            inherit pname version src;
            hash = "sha256-4jNci6ucFokvcDAA1C2g3hBN9ZSzu5R+CnxGVc3CM60=";
          };

          buildPhase = ''
            runHook preBuild

            ${getExe pkgs.pnpm} build

            runHook postBuild
          '';

          installPhase = ''
            runHook preInstall
            mkdir $out
            install -m0644 ./.hass/config/www/kiosk-mode.js $out

            runHook postInstall
          '';

          doDist = false;
        })
      ];
      config = {
        # Includes dependencies for a basic setup
        # https://www.home-assistant.io/integrations/default_config/
        default_config = { };
        homeassistant = {
          name = "Home";
          unit_system = "metric";
        };
        recorder.db_url = "postgresql:///hass";
        http = {
          use_x_forwarded_for = true;
          trusted_proxies = [ proxyIP ];
        };
        bluetooth = { };
        frontend = {
          themes = "!include_dir_merge_named themes";
        };
        mobile_app = { };
        smartir = { };
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
            name = "lock-front-door";
            label = "Lock front door";
            icon = "door_closed_lock";
          })
          (mkIosAction {
            name = "unlock-front-door";
            label = "Unlock front door";
            icon = "door_open";
          })
          (mkIosAction {
            name = "meow-nightlight";
            label = "Night";
            icon = "weather_night";
          })
          (mkIosAction {
            name = "meow-daylight";
            label = "Day";
            icon = "lightbulb_on";
          })
          (mkIosAction {
            name = "meow-turn-off-light";
            label = "Off";
            icon = "lightbulb_off";
          })
          (mkIosAction {
            name = "meow-60-sec-timer";
            label = "Turn off after 60 sec";
            icon = "timer_settings";
          })
          (mkIosAction {
            name = "meow-ac-instant-cooling";
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
                target = {
                  entity_id = "button.send_signal_light";
                };
              }
            ];
          }
          (mkIosAutomation {
            name = "lock-front-door";
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
            name = "unlock-front-door";
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
                data.sound = "US-EN-Alexa-Front-Door-Unlocked.wav";
              }
            ];
          })
          (mkIosAutomation {
            name = "meow-nightlight";
            action = [
              {
                service = "select.select_option";
                data = {
                  option = "1. On";
                };
                target = {
                  entity_id = "select.signals_light";
                };
              }
              {
                service = "button.press";
                target = {
                  entity_id = "button.send_signal_light";
                };
              }
              {
                service = "select.select_option";
                data = {
                  option = "8. Night";
                };
                target = {
                  entity_id = "select.signals_light";
                };
              }
              {
                service = "button.press";
                target = {
                  entity_id = "button.send_signal_light";
                };
              }
            ];
          })
          (mkIosAutomation {
            name = "meow-daylight";
            action = [
              {
                service = "select.select_option";
                data = {
                  option = "1. On";
                };
                target = {
                  entity_id = "select.signals_light";
                };
              }
              {
                service = "button.press";
                target = {
                  entity_id = "button.send_signal_light";
                };
              }
              {
                service = "select.select_option";
                data = {
                  option = "6. Daylight";
                };
                target = {
                  entity_id = "select.signals_light";
                };
              }
              {
                service = "button.press";
                target = {
                  entity_id = "button.send_signal_light";
                };
              }
              {
                service = "select.select_option";
                data = {
                  option = "5. Max";
                };
                target = {
                  entity_id = "select.signals_light";
                };
              }
              {
                service = "button.press";
                target = {
                  entity_id = "button.send_signal_light";
                };
              }
            ];
          })
          (mkIosAutomation {
            name = "meow-turn-off-light";
            action = [
              {
                service = "select.select_option";
                data = {
                  option = "2. Off";
                };
                target = {
                  entity_id = "select.signals_light";
                };
              }
            ];
          })
          (mkIosAutomation {
            name = "meow-ac-instant-cooling";
            action = [
              {
                service = "climate.turn_on";
                target = {
                  entity_id = "climate.ac_remo_mini";
                };
              }
              {
                service = "climate.set_temperature";
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
                data = {
                  swing_mode = "⥮5";
                };
                target = {
                  entity_id = "climate.ac_remo_mini";
                };
              }
              {
                service = "climate.set_fan_mode";
                data = {
                  fan_mode = "4";
                };
                target = {
                  entity_id = "climate.ac_remo_mini";
                };
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

    environment.persistence."/persist".directories =
      mkIf config.modules.sysconf.impermanence.enable
        (singleton {
          directory = "/var/lib/hass";
          user = "hass";
          group = "hass";
        });
  };
}
