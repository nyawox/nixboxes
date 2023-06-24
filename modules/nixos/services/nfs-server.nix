{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.services.nfs-server;
in {
  options = {
    modules.services.nfs-server = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };
  config = mkIf cfg.enable {
    services.nfs.server.enable = true;
    services.nfs.server.exports = ''
      /nixboxes *(rw,async,no_subtree_check)
      /mnt/hdd/transmission *(rw,async,no_subtree_check,all_squash,anonuid=1000,anongid=100)
      /var/backup *(rw,async,no_subtree_check,no_root_squash)
    '';
  };
}
