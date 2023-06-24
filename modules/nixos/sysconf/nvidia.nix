{
  config,
  lib,
  inputs,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.modules.sysconf.nvidia;
  package = config.boot.kernelPackages.nvidiaPackages.beta; # 565 supposedly fixes stutters in open nvidia module
in
{
  options = {
    modules.sysconf.nvidia = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
      modeSet = mkOption {
        type = types.bool;
        default = false;
      };
      prime = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };
  config = mkIf cfg.enable {
    modules.sysconf.hardening.overrides.compatibility = {
      no-lockdown = true;
      allow-unsigned-modules = true;
    };
    services.xserver.videoDrivers = [ "nvidia" ];
    boot.kernelParams = lib.mkMerge [
      # ["nvidia.NVreg_EnableGpuFirmware=0"] # Disable GSP Firmware. reduces stutter on wayland
      # prime offload automatically enables modeset
      (mkIf (!cfg.modeSet)
        # override it with priority, later kernel params are prioritized
        (mkAfter [ "nvidia-drm.modeset=0" ])
      )
    ];
    hardware = {
      graphics = {
        enable = mkDefault true;
        enable32Bit = mkDefault true;
      };
      nvidia = {
        modesetting.enable = mkIf (!cfg.modeSet) false;
        open = true; # open kernel modules rely on GSP (causing stutters) to work. https://github.com/NVIDIA/open-gpu-kernel-modules/issues/693
        powerManagement.enable = false;
        powerManagement.finegrained = false;
        nvidiaSettings = true;
        prime = mkIf cfg.prime {
          amdgpuBusId = "PCI:13:0:0";
          nvidiaBusId = "PCI:1:0:0";
          offload = {
            enable = true;
            enableOffloadCmd = true;
          };
          # reverseSync.enable = true; # supposed to make amdgpu the default
        };
        package = pkgs.nvidia-patch.patch-nvenc (pkgs.nvidia-patch.patch-fbc package);
      };
    };
    nixpkgs.overlays = [ inputs.nvidia-patch.overlays.default ];
  };
}
