{
  lib,
  config,
  inputs,
  ...
}:
with lib; let
  cfg = config.modules.shell.nix-index;
in {
  imports = [inputs.nix-index-database.hmModules.nix-index];
  options = {
    modules.shell.nix-index = {
      enable = mkOption {
        type = types.bool;
        default = true;
      };
    };
  };
  config = mkIf cfg.enable {
    programs.nix-index = {
      enable = true;
      symlinkToCacheHome = true;
      enableFishIntegration = false; # Use programsdb instead
    };
  };
}
