{
  inputs,
  self,
  lib,
  ...
}:
{
  flake = {
    deploy = {
      sshOpts = [
        "-t"
        "-p 22420"
        "-o ControlPath=none"
        "-o LogLevel=FATAL"
        "-o VisualHostKey=no"
      ];
      sudo = "sudo -u";
      fastConnection = true;
      autoRollback = true;
      magicRollback = false;
      nodes = builtins.mapAttrs (_: nixosConfig: {
        hostname =
          if
            builtins.isNull nixosConfig.config.modules.deploy.ip
          # Connection through Tailscale using MagicDNS
          then
            "${nixosConfig.config.networking.hostName}"
          else
            "${nixosConfig.config.modules.deploy.ip}";

        profiles.system = {
          user = "root";
          sshUser = "${nixosConfig.config.var.username}";
          path = nixosConfig.pkgs.deploy-rs.lib.activate.nixos nixosConfig;
        };
      }) (lib.filterAttrs (_: v: v.config.modules.deploy.enable) self.nixosConfigurations);
    };

    # This is highly advised, and will prevent many possible mistakes
    checks = builtins.mapAttrs (
      _system: deployLib: deployLib.deployChecks self.deploy
    ) inputs.deploy-rs.lib;
  };
}
