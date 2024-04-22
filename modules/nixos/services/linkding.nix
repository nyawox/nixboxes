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
    virtualisation.oci-containers.containers.linkding = {
      image = "docker.io/sissbruecker/linkding:latest";
      volumes = ["/var/lib/linkding:/etc/linkding/data"];
      ports = ["${builtins.toString cfg.port}:9090"];
      extraOptions = ["--label=io.containers.autoupdate=registry"];
      environment = {
        LD_SUPERUSER_NAME = "nyaa";
        LD_SUPERUSER_PASSWORD = "alpinerickroll"; # Change this
      };
    };
    environment.persistence."/persist".directories = mkIf config.modules.sysconf.impermanence.enable [
      "/var/lib/linkding"
    ];
    systemd.services.podman-linkding.after = ["var-lib-linkding.mount"];
  };
}
