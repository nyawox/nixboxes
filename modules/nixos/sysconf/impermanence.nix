{
  config,
  lib,
  inputs,
  username,
  ...
}:
with lib;
let
  cfg = config.modules.sysconf.impermanence;
in
{
  imports = [ inputs.impermanence.nixosModules.impermanence ];
  options = {
    modules.sysconf.impermanence = {
      enable = mkOption {
        type = types.bool;
        default = true;
      };
    };
  };
  config = mkIf cfg.enable {
    boot.tmp.cleanOnBoot = true;
    environment.persistence."/persist" = {
      hideMounts = true;
      directories = [
        "/var/log"
        "/var/tmp"
        "/var/lib/nixos"
        "/var/lib/systemd/coredump"
        "/var/lib/systemd/timesync/clock"
        "/var/lib/usbguard"
        # Add this globally to prevent permission issues
        {
          directory = "/var/lib/private/";
          user = "root";
          group = "root";
          mode = "700";
        }
        "/tmp"
      ];
      # files = [
      # Just an example with parent directory permissions don't enable { file = "/etc/nix/id_rsa"; parentDirectory = { mode = "u=rwx,g=,o="; }; }
      # ];
      users."${username}" = {
        directories = [
          "Downloads"
          "Music"
          "Pictures"
          "Documents"
          "Videos"
          "Projects"
          "Public"
          {
            directory = ".gnupg";
            mode = "703";
          }
          {
            directory = ".nixops";
            mode = "705";
          }
          {
            directory = ".local/share/keyrings";
            mode = "706";
          }
          ".var/app"
          ".local/share/direnv"
          ".local/share/zoxide"
          ".wine"
          ".cache"
          ".config/vesktop"
          ".config/uGet"
          ".config/transmission-remote-gtk"
          ".mozilla"
        ];
      };
    };
  };
}
