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
    services.nfs.server.exports =
      /*
      exports
      */
      ''
        /nixboxes *(rw,async,no_subtree_check)
      '';
  };
}
