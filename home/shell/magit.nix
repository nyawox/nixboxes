{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:
with lib; let
  cfg = config.modules.shell.magit;
in {
  options = {
    modules.shell.magit = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };
  imports = [
    inputs.nix-doom-emacs-unstraightened.hmModule
  ];
  config = mkIf cfg.enable {
    programs.doom-emacs = {
      enable = true;
      emacs = pkgs.emacs-unstable-nox;
      doomDir = ./doom.d;
    };
    services.emacs.enable = true;
    programs.nushell.shellAliases = {
      magit = "with-env { TERM: xterm-direct} {emacsclient -nw --eval '(magit-status)'}";
      mg = "magit";
    };
  };
}
