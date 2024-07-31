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
      port = mkOption {
        type = types.int;
        default = 11451;
      };
    };
  };
  config = mkIf cfg.enable {
    services.ollama = {
      enable = true;
      acceleration = "rocm";
      rocmOverrideGfx = "9.0.0";
      host = "[::]";
      inherit (cfg) port;
    };

    users = {
      groups.ollama = {};
      users.ollama = {
        group = "ollama";
        isSystemUser = true;
      };
    };
    environment.persistence."/persist".directories = mkIf config.modules.sysconf.impermanence.enable (singleton {
      directory = "/var/lib/private/ollama";
      user = "ollama";
      group = "ollama";
      mode = "750";
    });
    environment.persistence."/persist".users.${username}.directories = mkIf config.modules.sysconf.impermanence.enable [
      ".ollama"
    ];
    systemd.services.ollama.after = ["var-lib-ollama.mount"];
  };
}
