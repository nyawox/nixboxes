{
  lib,
  config,
  inputs,
  username,
  pkgs,
  ...
}:
with lib; let
  cfg = config.modules.desktop.gaming;
  gamePackages = with pkgs; [
    lutris
    prismlauncher
    cemu
    dolphin-emu
    rpcs3
    openrct2
    mangohud
    gamemode
  ];
in {
  imports = [inputs.jovian.nixosModules.default];
  options = {
    modules.desktop.gaming = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };
  config = {
    jovian.steamos.useSteamOSConfig = false; # for some reason this is enabled by default

    services.flatpak.packages = mkIf cfg.enable [
      "com.steamgriddb.SGDBoop"
      "io.github.limo_app.limo"
    ];
    jovian.steam.enable = mkIf cfg.enable true;
    # jovian.steamenvironment.ENABLE_GAMESCOPE_WSI = mkIf cfg.enable "0"; # games fails to launch without this when useSteamOSConfig option is enabled
    jovian.decky-loader.enable = mkIf cfg.enable true;
    environment.systemPackages = mkIf cfg.enable gamePackages;
    programs.steam = mkIf cfg.enable {
      enable = true;
      extraCompatPackages = with pkgs; [
        proton-ge-bin
        steamtinkerlaunch
      ];
      # extraPackages = gamePackages; # temporarily disable since steam-run-usr-target build always fails with a lot of collision warning and reccursive pixman-1 error
      protontricks.enable = true;
    };
    environment.persistence."/persist" = mkIf config.modules.sysconf.impermanence.enable {
      directories = mkIf cfg.enable ["/var/lib/decky-loader"];
      users."${username}" = mkIf cfg.enable {
        directories = [
          "Mods"
          ".local/share/Steam"
          ".local/share/lutris"
          ".config/rpcs3"
          ".local/share/yuzu"
          ".local/share/Cemu"
          ".local/share/dolphin-emu"
          ".config/dolphin-emu"
          ".config/OpenRCT2"
          ".local/share/umu"
          ".local/share/PrismLauncher"
          ".steam"
          ".config/lutris"
          ".config/Ryujinx"
        ];
      };
    };
  };
}
