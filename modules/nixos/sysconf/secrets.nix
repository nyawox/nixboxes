{
  config,
  lib,
  pkgs,
  inputs,
  username,
  ...
}:
with lib;
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
    sops = mkIf config.secrets.enable {
      defaultSopsFile = mkIf config.secrets.enable "/persist/dotfiles/secrets/secrets.yaml";
      #https://github.com/Mic92/sops-nix/issues/167
      gnupg.sshKeyPaths = mkIf config.secrets.enable [ ];
      # This will automatically import SSH keys as age keys
      # Don't forget to copy key there
      age.sshKeyPaths = mkIf config.secrets.enable [ "/persist/etc/ssh/id_ed25519_age" ];
      secrets.userpassword = mkIf config.secrets.enablePassword {
        neededForUsers = true;
        sopsFile = ../../../secrets/userpassword.yaml;
      };
    };
    users.users."${config.var.username
    }".hashedPasswordFile = mkIf config.secrets.enablePassword config.sops.secrets.userpassword.path;
    # sops.secrets.rootpassword = {
    #   neededForUsers = true;
    #   sopsFile = ./rootpassword.yaml;
    # };
    # users.users."root".hashedPasswordFile = config.sops.secrets.rootpassword.path;
    # Disable root
    users.users."root".hashedPassword = mkIf config.secrets.enablePassword "*";
    ignoredWarnings = [
      "The user '${username}' has multiple of the options\n`hashedPassword`, `password`, `hashedPasswordFile`, `initialPassword`\n& `initialHashedPassword` set to a non-null value.\nThe options silently discard others by the order of precedence\ngiven above which can lead to surprising results. To resolve this warning,\nset at most one of the options above to a non-`null` value.\n"
      "The user 'root' has multiple of the options\n`hashedPassword`, `password`, `hashedPasswordFile`, `initialPassword`\n& `initialHashedPassword` set to a non-null value.\nThe options silently discard others by the order of precedence\ngiven above which can lead to surprising results. To resolve this warning,\nset at most one of the options above to a non-`null` value.\n"
    ];

    environment.systemPackages = mkIf config.secrets.enable [ pkgs.sops ];

    environment.persistence."/persist".files = mkIf config.modules.sysconf.impermanence.enable [
      "/etc/ssh/id_ed25519_age"
      "/etc/ssh/id_ed25519_age.pub"
    ];
  };
}
