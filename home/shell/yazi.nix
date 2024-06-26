{
  lib,
  config,
  inputs,
  ...
}:
with lib; let
  cfg = config.modules.shell.yazi;
in {
  options = {
    modules.shell.yazi = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };
  config = mkIf cfg.enable {
    programs.yazi = {
      enable = true;
      enableFishIntegration = true;
    };
    xdg.configFile = {
      "yazi/theme.toml".source = inputs.catppuccin-yazi.outPath + "/themes/mocha.toml";
      "yazi/Catppuccin-mocha.tmTheme".source = inputs.catppuccin-bat.outPath + "/themes/Catppuccin Mocha.tmTheme";
    };
  };
}
