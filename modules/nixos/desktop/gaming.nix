# edid-decode failing to build
{
  lib,
  config,
  # inputs,
  username,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.modules.desktop.gaming;
  gamePackages = with pkgs; [
    prismlauncher
    dolphin-emu
    rpcs3
    openrct2
  ];
in
{
  # imports = [ inputs.jovian.nixosModules.default ];
  options = {
    modules.desktop.gaming = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };
  config = mkIf cfg.enable {
    modules.sysconf.maxmem.enable = mkForce true;
    services.flatpak.packages = [
      "com.steamgriddb.SGDBoop"
      "io.github.limo_app.limo"
    ];
    # jovian = {
    #   steam.enable = true;
    #   steam.updater.splash = "vendor";
    #   steamos.useSteamOSConfig = false;
    #   decky-loader.enable = true;
    #   # steam.environment.ENABLE_GAMESCOPE_WSI = mkIf cfg.enable "0"; # games fails to launch without this when useSteamOSConfig option is enabled
    # };
    programs.steam = {
      enable = true;
      extraPackages = gamePackages ++ [ pkgs.lutris-unwrapped ];
    };
    environment.systemPackages = gamePackages ++ [ pkgs.lutris ];
    environment.persistence."/persist" = mkIf config.modules.sysconf.impermanence.enable {
      directories = [ "/var/lib/decky-loader" ];
      users."${username}" = {
        directories = [
          "Mods"
          ".local/share/Steam"
          ".local/share/lutris"
          ".config/rpcs3"
          ".local/share/yuzu"
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
