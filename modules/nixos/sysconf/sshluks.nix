{
  config,
  lib,
  username,
  ...
}:
with lib; let
  cfg = config.modules.sysconf.sshluks;
in {
  options = {
    modules.sysconf.sshluks = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };
  config = mkIf cfg.enable {
    # ssh setup
    boot.initrd.network.enable = true;
    boot.initrd.network.ssh = {
      enable = true;
      port = 42420;
      authorizedKeys = config.users.users."${username}".openssh.authorizedKeys.keys;
      hostKeys = ["/persist/etc/secrets/initrd/ssh_host_ed25519_key"];
    };
    services.openssh.hostKeys = singleton {
      path = "/persist/etc/secrets/initrd/ssh_host_ed25519_key";
      type = "ed25519";
    };

    environment.persistence."/persist".directories =
      mkIf config.modules.sysconf.impermanence.enable
      ["/etc/secrets/initrd"];
  };
}
