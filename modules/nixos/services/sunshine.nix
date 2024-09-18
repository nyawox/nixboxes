{
  config,
  lib,
  pkgs,
  username,
  inputs,
  ...
}:
with lib; let
  cfg = config.modules.services.sunshine;
  dummy-output = "DP-2";
  steam-image = pkgs.fetchurl {
    url = "https://cdn2.steamgriddb.com/grid/39c2966989c4f0091a99eef7f1d09c09.png";
    sha256 = "18hka29nfwxj5xzfhxhy2ccjjaxhb8ir6v7wx0rs2lwc941r36b1";
  };
in {
  options = {
    modules.services.sunshine = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };
  config = mkIf cfg.enable {
    services.sunshine = {
      enable = true;
      # pairing not working on prerelease
      package = pkgs.sunshine.overrideAttrs (prev: {
        version = "v2024.916.233144";
        src = pkgs.fetchFromGitHub {
          owner = "LizardByte";
          repo = "Sunshine";
          rev = "v2024.916.233144";
          hash = "sha256-jNs/rLBHLvWmpRns143wSbPhJQd5RdbLJI/xJV4NDrE=";
          fetchSubmodules = true;
        };
        patches = [];
        cmakeFlags =
          prev.cmakeFlags
          ++ [
            (cmakeFeature "BOOST_USE_STATIC" "OFF")
            (cmakeFeature "BUILD_DOCS" "OFF")
            # workaround for issue 2778
            (cmakeFeature "SUNSHINE_ENABLE_TRAY" "0")
            (cmakeFeature "SUNSHINE_REQUIRE_TRAY" "0")
          ];
        buildInputs = lists.remove pkgs.boost prev.buildInputs ++ [pkgs.boost185];
        nativeBuildInputs = prev.nativeBuildInputs ++ [pkgs.nodejs];
      });
      autoStart = false; # let sway start it
      capSysAdmin = true;
      openFirewall = true;
      settings = {
        min_log_level = "info";
        capture = "wlr";
        encoder = "vaapi";
        address_family = "both";
        controller = "enabled";
        lan_encryption_mode = "0";
        wan_encryption_mode = "0";
      };
      applications = {
        env = {
          PATH = "/run/current-system/sw/bin:/run/wrappers/bin:/home/${username}/.nix-profile/bin:/etc/profiles/per-user/${username}/bin:/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin";
        };
        apps = [
          {
            name = "Steam";
            output = "steam.txt";
            prep-cmd = singleton {
              do = "${getExe pkgs.niri-unstable} msg action focus-monitor-left";
              undo = "${getExe pkgs.niri-unstable} msg action focus-monitor-right";
            };
            image-path = steam-image;
          }
        ];
      };
    };
    programs.sway.enable = true;
    home-manager.users."${username}" = {
      xdg.configFile."sway/config".text = let
        settingsFormat = pkgs.formats.keyValue {};
        configFile = settingsFormat.generate "sunshine.conf" config.services.sunshine.settings;
      in ''
        xwayland disable
        default_border none
        default_floating_border none
        exec ${config.security.wrapperDir}/sunshine ${configFile}
        exec ${getExe pkgs.bash} -c "while true; do ${getExe' inputs.jovian.legacyPackages.${pkgs.system}.gamescope-session "gamescope-session"}; done"
      '';

      programs.niri.settings = {
        window-rules = [
          {
            matches = singleton {
              app-id = "gamescope";
            };
            open-maximized = true;
            open-fullscreen = true;
          }
          # launch sway session on dummy monitor
          {
            matches = singleton {
              app-id = "wlroots";
            };
            open-maximized = true;
            open-fullscreen = true;
            open-on-output = dummy-output;
          }
        ];
        outputs."${dummy-output}" = {
          mode = {
            width = 1920;
            height = 1080;
            refresh = 60.000;
          };
          position.x = 25565;
          position.y = 0;
        };
        # auto start with niri
        spawn-at-startup = singleton {
          command = singleton "${getExe pkgs.sway}";
        };
      };
    };

    services.udev.extraRules =
      /*
      rules
      */
      ''
        KERNEL=="uinput", SUBSYSTEM=="misc", OPTIONS+="static_node=uinput", TAG+="uaccess"
        KERNEL=="uhid", TAG+="uaccess"
      '';
    boot = {
      kernelModules = ["uinput" "uhid"];
      # dummy monitor
      kernelParams = [
        "drm.edid_firmware=${dummy-output}:edid/aoc-c24g1-dp"
        "video=${dummy-output}:e"
      ];
    };
    hardware.firmware = let
      c24g1 = pkgs.fetchurl {
        url = "https://git.linuxtv.org/edid-decode.git/plain/data/aoc-c24g1-dp";
        sha256 = "14kz8hy8lqfqmmyac78j1y4jxlpabsc6k23s9688k8vbf3rq4125";
      };
    in [
      (pkgs.runCommandNoCC "dummymonitor" {} ''
        mkdir -p $out/lib/firmware/edid/
        cp "${c24g1}" $out/lib/firmware/edid/aoc-c24g1-dp
      '')
    ];

    environment.systemPackages = with pkgs; [sunshine];
    environment.persistence."/persist".users.${username} = {
      directories = [".config/sunshine/credentials"];
      files = [
        ".config/sunshine/sunshine_state.json"
        ".config/sunshine/sunshine.log"
      ];
    };
  };
}
