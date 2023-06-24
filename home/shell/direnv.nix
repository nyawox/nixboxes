{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.modules.shell.direnv;
in
{
  options = {
    modules.shell.direnv = {
      enable = mkOption {
        type = types.bool;
        default = true;
      };
    };
  };
  config = mkIf cfg.enable {
    home.packages = [
      # required for direnv
      pkgs.gnugrep
    ];
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };
}
