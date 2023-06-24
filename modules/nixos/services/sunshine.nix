{
  config,
  lib,
  pkgs,
  username,
  ...
}:
with lib;
let
  cfg = config.modules.services.sunshine;
  dummy-output = "DP-2";
  width = 1920;
  height = 1080;
  refresh = 120.0;
  steam-image = pkgs.fetchurl {
    url = "https://cdn2.steamgriddb.com/grid/39c2966989c4f0091a99eef7f1d09c09.png";
    sha256 = "18hka29nfwxj5xzfhxhy2ccjjaxhb8ir6v7wx0rs2lwc941r36b1";
  };
  sunshine =
    (pkgs.sunshine.override {
      cudaSupport = true;
      boost = pkgs.boost186;
    }).overrideAttrs
      (old: {
        pname = "sunshine";
        version = "portal-cherry";

        # nix-prefetch-github nyawox sunshine --rev cherry --fetch-submodules
        # don't forget to fetch submodules, it's required to build
        src = pkgs.fetchFromGitHub {
          owner = "nyawox";
          repo = "sunshine";
          rev = "bd9594f72744f69569b752a4c87044678be04363";
          hash = "sha256-M9iiuUYtjU3SZzFrOc5Tsos2i+6NKWEhAJOtW4XNKXk=";
          fetchSubmodules = true;
        };

        patches = [ ];

        nativeBuildInputs =
          with pkgs;
          old.nativeBuildInputs
          ++ [
            nodejs
            # portalgrab requires pipewire and gio, gio_unix
            pipewire
            glib
          ];

        cmakeFlags = old.cmakeFlags ++ [
          (lib.cmakeFeature "BOOST_USE_STATIC" "OFF")
          (lib.cmakeFeature "BUILD_DOCS" "OFF")
          (lib.cmakeFeature "CUDA_FAIL_ON_MISSING" "OFF")
        ];
      });
in
{
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
      autoStart = true;
      capSysAdmin = false;
      openFirewall = false; # only allow access through tailscale
      package = sunshine;
      settings = {
        min_log_level = "info";
        # failing because of the lack of RemoteDesktop protocol support
        capture = "portal";
        encoder = "nvenc";
        # output_name = "0";
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
    home-manager.users."${username}" = {
      programs.niri.settings = {
        window-rules = [
          {
            matches = singleton {
              app-id = "gamescope";
            };
            open-maximized = true;
            open-fullscreen = true;
            open-on-output = dummy-output;
          }
        ];
        outputs."${dummy-output}" = {
          mode = {
            inherit width height refresh;
          };
          position.x = 25565;
          position.y = 0;
        };
      };
    };

    services.udev.extraRules =
      # rules
      ''
        KERNEL=="uinput", SUBSYSTEM=="misc", OPTIONS+="static_node=uinput", TAG+="uaccess"
        KERNEL=="uhid", TAG+="uaccess"
      '';
    boot = {
      kernelModules = [
        "uinput"
        "uhid"
      ];
      # dummy monitor
      kernelParams = [
        "drm.edid_firmware=${dummy-output}:edid/aoc-c24g1-dp"
        "video=${dummy-output}:e"
      ];
    };
    hardware.firmware =
      let
        c24g1 =
          pkgs.fetchgit {
            url = "https://git.linuxtv.org/v4l-utils.git";
            rev = "363495b6df0dc30a0d63d49720ebbfa33f65c91f";
            hash = "sha256-dsfeYqfwdylQls64+jJvBDIUqoDOOwfvy3Xi0iJAVDI=";
          }
          + "/utils/edid-decode/data/aoc-c24g1-dp";
      in
      [
        (pkgs.runCommandNoCC "dummymonitor" { } ''
          mkdir -p $out/lib/firmware/edid/
          cp "${c24g1}" $out/lib/firmware/edid/aoc-c24g1-dp
        '')
      ];

    environment.systemPackages = [ sunshine ];
    environment.persistence."/persist".users.${username} = {
      directories = [ ".config/sunshine/credentials" ];
      files = [
        ".config/sunshine/sunshine_state.json"
        ".config/sunshine/sunshine.log"
      ];
    };
  };
}
