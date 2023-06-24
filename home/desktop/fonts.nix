{
  lib,
  config,
  osConfig,
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
    home.packages = osConfig.fonts.packages;
    fonts.fontconfig = {
      enable = true;
      defaultFonts = {
        emoji = [
          "Apple Color Emoji"
        ];
      };
    };
    home.sessionVariables.FREETYPE_PROPERTIES = "truetype:interpreter-version=40 autofitter:no-stem-darkening=0 cff:no-stem-darkining=0 type1:no-stem-darkening=0 t1cid:no-stem-darkening=0";
  };
}
