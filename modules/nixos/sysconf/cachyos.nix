{
  config,
  lib,
  inputs,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.modules.sysconf.cachyos;
in
{
  options = {
    modules.sysconf.cachyos = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          use linux-cachyos with sched-ext
        '';
      };
    };
  };
  imports = [
    inputs.chaotic.nixosModules.default
  ];
  config = mkIf cfg.enable {
    # don't have time to debug
    # some kind of kernel parameter breaks this. related to bpf,
    # but allowing unprivileged bpf isn't enough
    # chaotic.scx = {
    #   enable = true;
    #   package = pkgs.scx_git.rustland;
    #   scheduler = "scx_rustland";
    # };
    boot.kernelPackages = pkgs.linuxPackages_cachyos;
  };
}
