{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
with lib; let
  cfg = config.modules.services.minecraft-server;
in {
  imports = [inputs.nix-minecraft.nixosModules.minecraft-servers];
  options = {
    modules.services.minecraft-server = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };
  config = mkIf cfg.enable {
    nixpkgs.overlays = [inputs.nix-minecraft.overlay];
    services = {
      minecraft-server.dataDir = "/var/lib/minecraft/null";
      minecraft-servers = {
        enable = true;
        eula = true;
        openFirewall = false;
        dataDir = "/var/lib/minecraft";
        servers.wanwan = {
          enable = true;
          autoStart = false;
          package = pkgs.paperServers.paper;
          # see here for more info: https://minecraft.gamepedia.com/Server.properties#server.properties
          serverProperties = {
            server-port = 43257;
            gamemode = "survival";
            difficulty = "normal";
            motd = "にっこにっこにー(＊◕ᴗ◕＊)";
            max-players = 5;
            enable-rcon = true;
            # This password can be used to administer your minecraft server.
            # Exact details as to how will be explained later. If you want
            # you can replace this with another password.
            "rcon.password" = "rickroll69";
            level-seed = "10292992";
          };
          symlinks = {
            # "server-icon.png" = pkgs.fetchurl {
            #   url = "https://cdn.discordapp.com/attachments/1158393833034362943/1178081388780585000/server-icon.png?ex=6574d8ca&is=656263ca&hm=17e8ec689a89dd9cfb2767f2b7444a796771b35e7afe41310c1d41ceba6cbb5d&";
            #   sha256 = "1mmy548qrihys20wxrlcb043mrw3904arnir6wm7n4ldmkkj88qc";
            # };
          };
        };
      };
      frp = {
        enable = true;
        role = "client";
        settings = {
          common = {
            server_addr = "vultr.nyaa.nixlap.top";
            server_port = 7034;
          };
          proxies = {
            name = "minecraft";
            type = "tcp";
            local_ip = "127.0.0.1";
            local_port = 43257;
            remote_port = 25565;
          };
        };
      };
      restic.backups.minecraft-local = {
        initialize = true;
        paths = [
          "/var/lib/minecraft/wanwan/world"
          "/var/lib/minecraft/wanwan/world_nether"
          "/var/lib/minecraft/wanwan/world_the_end"
        ];
        passwordFile = config.sops.secrets.restic-minecraft-pw.path;
        repository = "/var/backup/minecraft";
        timerConfig = {
          # backup every 1d
          OnUnitActiveSec = "1d";
        };
        # keep 7 daily, 5 weekly, and 10 annual backups
        pruneOpts = [
          "--keep-daily 7"
          "--keep-weekly 5"
          "--keep-yearly 10"
        ];
      };
    };
    environment.systemPackages = with pkgs; [
      rcon
      tmux
    ];
    environment.persistence."/persist".directories = mkIf config.modules.sysconf.impermanence.enable (lib.singleton {
      directory = "/var/lib/minecraft";
      user = "minecraft";
      group = "minecraft";
    });
    sops.secrets.restic-minecraft-pw = {
      sopsFile = ../../../secrets/restic-minecraft.psk;
      format = "binary";
    };
  };
}
