{
  config,
  lib,
  pkgs,
  username,
  ...
}:
with lib; let
  cfg = config.modules.services.sunshine;
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
      # comment this to pair new devices
      package = pkgs.sunshine.overrideAttrs (prev: {
        version = "git-2024-08-10";
        src = pkgs.fetchFromGitHub {
          owner = "LizardByte";
          repo = "Sunshine";
          rev = "f9c885a414f92d8277337e2fd1283110a0e376bb";
          hash = "sha256-gsuhRk2gBLg+6VQzK3eW4xTroMSGR4MUgpyw4xFLb3g=";
          fetchSubmodules = true;
        };
        patches = [];
        cmakeFlags =
          prev.cmakeFlags
          ++ [
            (cmakeFeature "BOOST_USE_STATIC" "OFF")
            (cmakeFeature "BUILD_DOCS" "OFF")
          ];
        buildInputs = lists.remove pkgs.boost prev.buildInputs ++ [pkgs.boost185];
        nativeBuildInputs = prev.nativeBuildInputs ++ [pkgs.nodejs];
      });
      capSysAdmin = true;
      openFirewall = true;
      settings = {
        min_log_level = "info";
        output_name = "1";
        encoder = "software";
        controller = "enabled";
        gamepad = "ds5";
        address_family = "both";
      };
      applications = {
        env = {
          PATH = "/run/current-system/sw/bin:/run/wrappers/bin:/home/${username}/.nix-profile/bin:/etc/profiles/per-user/${username}/bin:/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin";
        };
        apps = [
          {
            name = "Steam";
            output = "steam.txt";
            detached = [
              "${getExe pkgs.gamescope} -f --force-grab-cursor -- steam-gamescope"
            ];
            prep-cmd = [
              {
                do = "${getExe pkgs.niri-unstable} msg action focus-monitor-right";
                undo = "${pkgs.procps}/bin/pkill steam";
              }
            ];
            image-path = "steam.png";
          }
        ];
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
        "drm.edid_firmware=DP-2:edid/aoc-c24g1-dp"
        "video=DP-2:e"
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
