{
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.modules.shell.zoxide;
in
{
  options = {
    modules.shell.zoxide = {
      enable = mkOption {
        type = types.bool;
        default = true;
      };
    };
  };
  config = mkIf cfg.enable {
    programs.zoxide = {
      enable = true;
      options = [
        "--cmd cd" # just to stop me using cd
      ];
    };
    home.sessionVariables._ZO_FZF_OPTS = "--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 --color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc --color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8";
    programs.nushell.shellAliases = {
      j = "cd"; # j is easier to press than z on my layout
      ji = "cdi";
    };
  };
}
