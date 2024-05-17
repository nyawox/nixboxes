{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.services.linkding;
in {
  options = {
    modules.services.linkding = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
      port = mkOption {
        type = types.int;
        default = 9090;
      };
    };
  };
  config = mkIf cfg.enable {
    modules.virtualisation.arion.enable = lib.mkForce true;
    virtualisation.arion.projects.linkding.settings = {
      project.name = "linkding";
      services.linkding.service = {
        image = "docker.io/sissbruecker/linkding:latest";
        volumes = ["/var/lib/linkding:/etc/linkding/data"];
        ports = ["${builtins.toString cfg.port}:9090"];
        environment = {
          LD_SUPERUSER_NAME = "nyaa";
          LD_SUPERUSER_PASSWORD = "alpinerickroll"; # Change this
        };
        labels."io.containers.autoupdate" = "registry";
      };
    };
    environment.persistence."/persist".directories = mkIf config.modules.sysconf.impermanence.enable [
      "/var/lib/linkding"
    ];
    systemd.services.arion-linkding.after = ["var-lib-linkding.mount"];
  };
}
