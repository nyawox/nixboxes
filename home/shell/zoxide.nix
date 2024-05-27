{ lib, config, ... }:
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
    programs.fish.shellAliases = {
      j = "cd"; # j is easier to press than z on my layout
      ji = "cdi";
    };
  };
}
