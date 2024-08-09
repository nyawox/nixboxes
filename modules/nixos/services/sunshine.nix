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
        encoder = "vaapi";
        controller = "enabled";
        gamepad = "ds5";
        lan_encryption_mode = "2";
        wan_encryption_mode = "2";
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
        "drm.edid_firmware=HDMI-A-1:edid/samsung-q800t-hdmi2.1"
        "video=HDMI-A-1:e"
      ];
    };
    hardware.firmware = let
      q800t = pkgs.fetchurl {
        url = "https://git.linuxtv.org/edid-decode.git/plain/data/samsung-q800t-hdmi2.1";
        sha256 = "0r3v1mzpkalgdhnnjfq8vbg4ian3pwziv0klb80zw89w1msfm9nh";
      };
    in [
      (pkgs.runCommandNoCC "dummymonitor" {} ''
        mkdir -p $out/lib/firmware/edid/
        cp "${q800t}" $out/lib/firmware/edid/samsung-q800t-hdmi2.1
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
