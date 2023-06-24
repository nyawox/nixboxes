{
  lib,
  config,
  inputs,
  ...
}:
with lib;
let
  cfg = config.modules.shell.gitui;
in
{
  options = {
    modules.shell.gitui = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };
  config = mkIf cfg.enable {
    programs.gitui = {
      enable = true;
      theme = builtins.readFile "${inputs.catppuccin-gitui.outPath}/themes/catppuccin-mocha.ron";
    };
  };
}
