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
        "/etc/NetworkManager/system-connections"
        "/tmp"
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
          "VirtualBox VMs"
          "Projects"
          "Games"
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
          "PopTracker"
          ".local/share/direnv"
          ".local/share/Steam"
          ".local/share/yuzu"
          ".local/share/Cemu"
          ".local/share/dolphin-emu"
          ".config/dolphin-emu"
          ".local/share/lutris"
          ".local/share/TelegramDesktop"
          ".local/share/PrismLauncher/instances"
          ".local/share/PrismLauncher/logs"
          ".local/share/PrismLauncher/translations"
          ".local/share/PrismLauncher/meta"
          ".local/share/zoxide"
          ".wine"
          ".cache"
          ".steam"
          ".zephyr"
          ".config/Vencord"
          ".config/VencordDesktop"
          ".config/discord"
          ".config/emacs"
          ".config/citra-emu"
          ".config/rpcs3"
          ".config/heroic"
          ".config/lutris"
          ".config/transmission-remote-gtk"
          ".mozilla"
          # ".mozilla/firefox/default/storage"
        ];
        files = [
          ".config/pulse/cookie"
          ".local/share/PrismLauncher/prismlauncher.cfg"
          ".local/share/PrismLauncher/accounts.json"
          ".local/share/PrismLauncher/metacache"
          # ".mozilla/firefox/default/addons.json"
          # ".mozilla/firefox/default/addonStartup.json.lz4"
          # ".mozilla/firefox/default/extension-preferences.json"
          # ".mozilla/firefox/default/extension-settings.json"
          # ".mozilla/firefox/default/extensions.json"
          # ".mozilla/firefox/default/key4.db"
          # ".mozilla/firefox/default/logins.json"
          # ".mozilla/firefox/default/permissions.sqlite"
          # ".mozilla/firefox/default/cookies.sqlite"
          # ".mozilla/firefox/default/cookies.sqlite-wal"
        ];
      };
    };
  };
}
