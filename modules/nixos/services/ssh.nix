{
  config,
  lib,
  username,
  ...
}:
with lib;
let
  cfg = config.modules.services.ssh;
in
{
  options = {
    modules.services.ssh = {
      enable = mkOption {
        type = types.bool;
        default = true;
      };
    };
  };
  config = mkIf cfg.enable {
    services.openssh = {
      enable = true;
      openFirewall = false;
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        X11Forwarding = false;
      };
      extraConfig =
        # conf
        ''
          AllowTcpForwarding yes
          AllowAgentForwarding no
          AllowStreamLocalForwarding no
          AllowUsers nyaa
          AuthenticationMethods publickey
          # Listen to all ipv4 adderss
          ListenAddress 0.0.0.0
          # Listen to all ipv6 address
          ListenAddress ::
        '';
      ports = [ 22420 ];
      hostKeys = singleton {
        path = "/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      };
    };
    # make accesible from my desktop
    users.users."${username}".openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ+HhlLh3dtTBvWN6WO8gHma2BoGupqhjVuy2raQ+JS2 nyawox.git@gmail.com"
    ];
    # Smoother ssh
    programs.mosh.enable = true;

    environment.persistence."/persist" = {
      directories = mkIf config.modules.sysconf.impermanence.enable [ "/root/.ssh" ];
      files = mkIf config.modules.sysconf.impermanence.enable [
        "/etc/ssh/ssh_host_ed25519_key"
        "/etc/ssh/ssh_host_ed25519_key.pub"
      ];
      users."${username}".directories = singleton {
        directory = ".ssh";
        mode = "704";
      };
    };
    modules.services.fail2ban.enable = mkForce true;
    # nixos comes with default sshd jail, no need to set port manually
    services.fail2ban.jails.sshd.settings = {
      enabled = true;
      action = "endlessh";
      mode = "aggressive";
    };
  };
}
