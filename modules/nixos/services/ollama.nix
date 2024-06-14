{
  config,
  lib,
  username,
  ...
}:
with lib; let
  cfg = config.modules.services.ollama;
in {
  options = {
    modules.services.ollama = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };
  config = mkIf cfg.enable {
    services.ollama = {
      enable = true;
      acceleration = "rocm";
      host = "0.0.0.0";
      port = 11451;
    };
    nixpkgs.config.rocmSupport = true;
    environment.persistence."/persist" = mkIf config.modules.sysconf.impermanence.enable {
      users."${username}" = {
        directories = [
          "/ollama"
        ];
      };
    };
  };
}
