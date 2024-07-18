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
    fonts = {
      fontDir = {
        enable = true;
        decompressFonts = true;
      };
      packages = with pkgs; [
        corefonts
        spleen
        apple-emoji
        liberation_ttf
        wqy_zenhei
        font-awesome
        poppins
        noto-fonts-cjk
        fast-font
        (nerdfonts.override {fonts = ["NerdFontsSymbolsOnly"];})
      ];
      fontconfig.defaultFonts = {
        emoji = [
          "Apple Color Emoji"
        ];
      };
    };
  };
}
