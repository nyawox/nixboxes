{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.modules.desktop.fonts;
in
{
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
        noto-fonts-cjk-sans
        fast-font
        nerd-fonts.symbols-only
      ];
      fontconfig = {
        enable = true;
        antialias = true;
        hinting = {
          enable = true;
          style = "full";
        };
        subpixel = {
          rgba = "rgb";
          lcdfilter = "default";
        };
        defaultFonts = {
          emoji = [
            "Apple Color Emoji"
          ];
        };
      };
    };
    environment.variables = {
      FREETYPE_PROPERTIES = "truetype:interpreter-version=40 autofitter:no-stem-darkening=0 cff:no-stem-darkining=0 type1:no-stem-darkening=0 t1cid:no-stem-darkening=0";
    };
  };
}
