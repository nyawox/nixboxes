{
  lib,
  config,
  osConfig,
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
    home.packages = osConfig.fonts.packages;
    fonts.fontconfig = {
      enable = true;
      defaultFonts = {
        emoji = [
          "Apple Color Emoji"
        ];
      };
    };
  };
}
