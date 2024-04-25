{
  pkgs,
  lib,
  ...
}: {
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
}
