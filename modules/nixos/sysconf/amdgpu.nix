{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.modules.sysconf.amdgpu;
  pptFile = ./amdgpu_ppt.bin;
  card = "card0"; # TODO ensure card0 is always amdgpu
  writePowerPlay = pkgs.writeShellScript "writePowerPlay" ''
    cp ${pptFile} /sys/class/drm/${card}/device/pp_table
  '';
in
{
  options = {
    modules.sysconf.amdgpu = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
      modeSet = mkOption {
        type = types.bool;
        default = false;
      };
      disableEfiFb = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };
  config = mkIf cfg.enable {
    services.xserver.videoDrivers = [ "amdgpu" ];

    boot.kernelParams = mkIf cfg.modeSet [
      "amdgpu.modeset=1"
      "amdgpu.dc=1" # displaycore
      "amdgpu.ppfeaturemask=0xffffffff" # enable overclocking
      (mkIf cfg.disableEfiFb "video=efifb:off")
    ];
    hardware = {
      graphics = {
        enable = mkDefault true;
        enable32Bit = mkDefault true;
        extraPackages = with pkgs; [
          vaapiVdpau
          libvdpau-va-gl
        ];
      };
      amdgpu = {
        initrd.enable = true;
        opencl.enable = true;
      };
    };
    systemd.services.amdgpu-ppt = {
      enable = true;
      description = "Enable AMDGPU custom PowerPlay table";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = "${writePowerPlay}";
        Restart = "on-failure";
        RestartSec = "60s";
      };
    };
    # overclock, undervolt, set fan curves
    environment.systemPackages = with pkgs; [ lact ];
    systemd.packages = with pkgs; [ lact ];
    # systemd.services.lactd.wantedBy = ["multi-user.target"];
    environment.persistence."/persist".directories =
      lib.mkIf config.modules.sysconf.impermanence.enable
        [
          "/etc/lact"
        ];
  };
}
