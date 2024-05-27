{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:
with lib;
let
  cfg = config.modules.desktop.emacs;
in
{
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
      extraPackages = epkgs: [ epkgs.vterm ];
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
        ".doom.d/splash.png".source = inputs.doom-banners.outPath + "/splashes/emacs/emacs-e-logo.png";
      };

      packages = with pkgs; [
        python3
        ripgrep
        # formatter
        nixfmt-rfc-style
        # Language servers
        nil
        emmet-ls
        nodePackages.typescript-language-server
        haskell-language-server
        yaml-language-server
        nodePackages.bash-language-server
      ];
    };
    programs.fish.shellAliases = mkIf config.modules.shell.fish.enable {
      magit = "TERM=xterm-direct emacsclient -nw --eval '(magit-status)'";
    };
  };
}
