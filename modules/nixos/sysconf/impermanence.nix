{
  config,
  lib,
  username,
  ...
}:
with lib; let
  cfg = config.modules.sysconf.impermanence;
in {
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
        {
          directory = "/var/lib/colord";
          user = "colord";
          group = "colord";
          mode = "u=rwx,g=rx,o=";
        }
        # Add this globally to prevent permission issues
        {
          directory = "/var/lib/private/";
          user = "root";
          group = "root";
          mode = "700";
        }
        "/etc/NetworkManager/system-connections"
        "/tmp"
        "/root/.ssh"
      ];
      files = [
        "/etc/machine-id"
        # Just an example with parent directory permissions don't enable { file = "/etc/nix/id_rsa"; parentDirectory = { mode = "u=rwx,g=,o="; }; }
      ];
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
            directory = ".ssh";
            mode = "704";
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
          ".local/state/wireplumber"
          ".local/share/direnv"
          ".local/share/zoxide"
          ".wine"
          ".cache"
          ".config/vesktop"
          ".config/uGet"
          ".config/emacs"
          ".config/transmission-remote-gtk"
          ".config/Youtube Music"
          ".config/Cider"
          ".mozilla"
        ];
        files = [
          ".config/pulse/cookie"
        ];
      };
    };
  };
}
