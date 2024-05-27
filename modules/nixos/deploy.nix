{
  config,
  lib,
  hostname,
  username,
  ...
}:
with lib;
let
  cfg = config.modules.deploy;
in
{
  options = {
    modules.deploy = {
      enable = mkOption {
        type = types.bool;
        default = true;
      };
      ip = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Overwrite the IP to deploy";
      };
      noPass = mkOption {
        type = types.bool;
        default = true;
      };
    };
  };
  config = mkIf cfg.enable {
    security.sudo-rs.extraRules = mkIf cfg.noPass [
      {
        users = [ "${username}" ];
        commands = [
          {
            command = "/nix/store/*-activatable-nixos-system-${hostname}-*/activate-rs";
            options = [ "NOPASSWD" ];
          }
        ];
      }
    ];
  };
}
