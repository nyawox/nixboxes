{
  lib,
  config,
  inputs,
  ...
}:
with lib;
let
  cfg = config.modules.shell.bat;
in
{
  options = {
    modules.shell.bat = {
      enable = mkOption {
        type = types.bool;
        default = true;
      };
    };
  };
  config = mkIf cfg.enable {
    programs.bat = {
      enable = true;
      config = {
        pager = "less -FR";
        theme = "Catppuccin Mocha";
      };
    };
    xdg.configFile = {
      "bat/themes/Catppuccin Mocha.tmTheme".source =
        inputs.catppuccin-bat.outPath + "/themes/Catppuccin Mocha.tmTheme";
    };
    home.sessionVariables = {
      MANPAGER = "sh -c 'col -bx | bat -l man -p'";
      MANROFFOPT = "-c";
    };
  };
}
