{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.services.minecraft-server;
in {
  options = {
    modules.services.minecraft-server = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };
  config = mkIf cfg.enable {
    services.minecraft-server = {
      enable = true;
      eula = true;
      declarative = true;
      # see here for more info: https://minecraft.gamepedia.com/Server.properties#server.properties
      serverProperties = {
        server-port = 25565;
        gamemode = "survival";
        motd = ":)";
        max-players = 5;
        enable-rcon = true;
        # This password can be used to administer your minecraft server.
        # Exact details as to how will be explained later. If you want
        # you can replace this with another password.
        "rcon.password" = "rickroll69";
        level-seed = "10292992";
      };
    };
    environment.persistence."/persist".directories = mkIf config.modules.sysconf.impermanence.enable [
      {
        directory = "/var/lib/minecraft";
        user = "minecraft";
        group = "minecraft";
      }
    ];
    services.frp = {
      enable = true;
      role = "client";
      settings = {
        common = {
          server_addr = "vultr.nyaa.nixhome.shop";
          server_port = 7034;
        };
        proxies = {
          name = "minecraft";
          type = "tcp";
          local_ip = "127.0.0.1";
          local_port = 25565;
          remote_port = 25565;
        };
      };
    };
  };
}
