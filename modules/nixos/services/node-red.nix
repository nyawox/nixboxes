{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.modules.services.node-red;
in {
  options = {
    modules.services.node-red = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };
  config = mkIf cfg.enable {
    services.node-red = {
      enable = true;
      package = pkgs.nodePackages.node-red;
      openFirewall = false;
      withNpmAndGcc = true;
    };
  };
}
