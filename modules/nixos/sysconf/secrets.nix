{
  config,
  lib,
  pkgs,
  inputs,
  username,
  ...
}:
with lib;
let
  cfg = config.secrets;
in
{
  imports = [ inputs.sops-nix.nixosModules.sops ];
  options.secrets = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Enable secrets in your system
      '';
    };
    enablePassword = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Enable password from secrets
      '';
    };
  };
  config = {
    sops = mkIf cfg.enable {
      defaultSopsFile = "/persist/dotfiles/secrets/secrets.yaml"; # non existent path
      #https://github.com/Mic92/sops-nix/issues/167
      gnupg.sshKeyPaths = [ ];
      # This will automatically import SSH keys as age keys
      # Don't forget to copy key there
      age.sshKeyPaths = [ "/persist/etc/ssh/id_ed25519_age" ];
      secrets.userpassword = mkIf cfg.enablePassword {
        neededForUsers = true;
        sopsFile = ../../../secrets/userpassword.yaml;
      };
      secrets."nix-access-tokens" = {
        sopsFile = ../../../secrets/nix-access-tokens.conf;
        format = "binary";
        owner = username;
      };
    };
    users.users."${config.var.username}" = mkIf cfg.enablePassword {
      hashedPasswordFile = config.sops.secrets.userpassword.path;
      password = mkForce null;
    };
    # sops.secrets.rootpassword = {
    #   neededForUsers = true;
    #   sopsFile = ./rootpassword.yaml;
    # };
    # users.users."root".hashedPasswordFile = config.sops.secrets.rootpassword.path;
    # Disable root
    users.users."root".hashedPassword = mkIf cfg.enablePassword "*";
    systemd.enableEmergencyMode = mkIf cfg.enablePassword false; # this makes no sense with root password disabled
    ignoredWarnings = [
      "The user '${username}' has multiple of the options\n`hashedPassword`, `password`, `hashedPasswordFile`, `initialPassword`\n& `initialHashedPassword` set to a non-null value.\nThe options silently discard others by the order of precedence\ngiven above which can lead to surprising results. To resolve this warning,\nset at most one of the options above to a non-`null` value.\n"
      "The user 'root' has multiple of the options\n`hashedPassword`, `password`, `hashedPasswordFile`, `initialPassword`\n& `initialHashedPassword` set to a non-null value.\nThe options silently discard others by the order of precedence\ngiven above which can lead to surprising results. To resolve this warning,\nset at most one of the options above to a non-`null` value.\n"
    ];

    environment.systemPackages = [ pkgs.sops ];

    environment.persistence."/persist".files = mkIf config.modules.sysconf.impermanence.enable [
      "/etc/ssh/id_ed25519_age"
      "/etc/ssh/id_ed25519_age.pub"
    ];
  };
}
