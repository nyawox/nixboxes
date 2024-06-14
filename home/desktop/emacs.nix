{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:
with lib; let
  cfg = config.modules.desktop.emacs;
in {
  options = {
    modules.desktop.emacs = {
      enable = mkOption {
        type = types.bool;
        default = true;
      };
    };
  };
  config = mkIf cfg.enable {
    programs.emacs = {
      enable = true;
      package = pkgs.emacs29-pgtk;
    };
    services.emacs.enable = true;
    home = {
      file = {
        ".doom.d" = {
          source = ./doom.d;
          recursive = true;
        };
        ".doom.d/themes/catppuccin-theme.el".source =
          inputs.catppuccin-emacs.outPath + "/catppuccin-theme.el";
      };
    };
    programs.fish.shellAliases = mkIf config.modules.shell.fish.enable {
      magit = "TERM=xterm-direct emacsclient -nw --eval '(magit-status)'";
      mg = "magit";
    };
  };
}
