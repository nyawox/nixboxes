{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.services.nfs-client;
in {
  options = {
    modules.services.nfs-client = {
      nixboxes = mkOption {
        type = types.bool;
        default = false;
      };
      backups = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };
  config = {
    fileSystems = {
      "/nixboxes" = mkIf cfg.nixboxes {
        device = "lolcathost.nyaa.nixlap.top:/nixboxes";
        fsType = "nfs";
        options = ["nfsvers=4.2" "x-systemd.automount" "noauto" "async"];
      };
      "/var/backup" = mkIf cfg.backups {
        device = "lolcathost.nyaa.nixlap.top:/var/backup";
        fsType = "nfs";
        options = ["nfsvers=4.2" "x-systemd.automount" "noauto" "async"];
      };
    };
  };
}
