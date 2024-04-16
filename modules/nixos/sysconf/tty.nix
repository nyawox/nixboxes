{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.modules.sysconf.tty;
in {
  options = {
    modules.sysconf.tty = {
      enable = mkOption {
        type = types.bool;
        default = true;
      };
    };
  };
  config = mkIf cfg.enable {
    # Configure console font
    console.packages = with pkgs; [spleen];
    console.font = "${pkgs.spleen}/share/consolefonts/spleen-8x16.psfu";

    # Catppuccin Mocha
    boot.kernelParams = [
      "vt.default_red=30,243,166,249,137,245,148,186,88,243,166,249,137,245,148,166"
      "vt.default_grn=30,139,227,226,180,194,226,194,91,139,227,226,180,194,226,173"
      "vt.default_blu=46,168,161,175,250,231,213,222,112,168,161,175,250,231,213,200"
    ];
  };
}
