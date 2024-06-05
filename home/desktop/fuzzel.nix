{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.modules.desktop.fuzzel;
in {
  options = {
    modules.desktop.fuzzel = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };
  config = mkIf cfg.enable {
    programs.fuzzel = {
      enable = true;
      settings = {
        main = {
          terminal = "${pkgs.foot}/bin/foot";
          font = lib.mkForce "Poppins:size=20";
          layer = "overlay";
        };
        colors.background = lib.mkForce "1e1e2efa"; # 0.95 opacity
      };
    };
  };
}
