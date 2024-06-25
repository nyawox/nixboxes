{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.modules.desktop.fonts;
in {
  options = {
    modules.desktop.fonts = {
      enable = mkOption {
        type = types.bool;
        default = true;
      };
    };
  };
  config = mkIf cfg.enable {
    fonts.fontDir = {
      enable = true;
      decompressFonts = true;
    };
    fonts.packages = with pkgs; [
      corefonts
      spleen
      apple-emoji
      liberation_ttf
      wqy_zenhei
      font-awesome
      (nerdfonts.override {fonts = ["NerdFontsSymbolsOnly"];})
    ];
    fonts.fontconfig.defaultFonts = {
      emoji = [
        "Apple Color Emoji"
      ];
    };
  };
}
