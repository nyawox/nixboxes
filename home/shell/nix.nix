# nix user config
{
  lib,
  config,
  osConfig,
  ...
}:
with lib;
let
  cfg = config.modules.shell.nix;
in
{
  options = {
    modules.shell.nix = {
      enable = mkOption {
        type = types.bool;
        default = true;
      };
    };
  };
  config = mkIf cfg.enable {
    nix = {
      settings = {
        experimental-features = [
          "nix-command"
          "flakes"
          "repl-flake"
        ];
      };
      extraOptions =
        # conf
        ''
          min-free = ${toString (100 * 1024 * 1024)}
          max-free = ${toString (1024 * 1024 * 1024)}
          builders-use-substitutes = true
          !include ${optionalString osConfig.secrets.enable (toString osConfig.sops.secrets.nix-access-tokens.path)}
        '';
    };
  };
}
