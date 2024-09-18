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
    inputs.nixpkgs-yuzu.legacyPackages.${pkgs.system}.citra
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
  config = mkIf cfg.enable {
    jovian = {
      steam = {
        enable = true;
        # environment.ENABLE_GAMESCOPE_WSI = "0"; # games fails to launch without this when SteamOSConfig option is enabled
      };
      steamos.useSteamOSConfig = false;
      decky-loader.enable = true;
    };
    environment.systemPackages = gamePackages;
    programs.steam = {
      enable = true;
      extraCompatPackages = with pkgs; [
        proton-ge-bin
        steamtinkerlaunch
      ];
      extraPackages = gamePackages;
      protontricks.enable = true;
    };
    environment.persistence."/persist" = mkIf config.modules.sysconf.impermanence.enable {
      directories = ["/var/lib/decky-loader"];
      users."${username}" = {
        directories = [
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
        ];
      };
    };
  };
}
