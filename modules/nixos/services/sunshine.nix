{
  config,
  lib,
  pkgs,
  username,
  ...
}:
with lib;
let
  cfg = config.modules.services.sunshine;
  steam = pkgs.steam.override {
    extraPkgs =
      pkgs: with pkgs; [
        heroic
        prismlauncher
        wineWowPackages.stable
        gamescope
        mangohud
      ];
  };
in
{
  options = {
    modules.services.sunshine = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };
  config = mkIf cfg.enable {
    security.wrappers.sunshine = {
      owner = "root";
      group = "root";
      capabilities = "cap_sys_admin+p";
      source = "${pkgs.sunshine}/bin/sunshine";
    };

    systemd.user.services.sunshine = {
      enable = true;
      description = "sunshine";
      wantedBy = [ "graphical-session.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.gamescope}/bin/gamescope -e -w 1920 -W 1920 -H 1080 -h 1080 -r 60 -- ${pkgs.bash}/bin/bash -c '${config.security.wrapperDir}/sunshine'";
        Environment = "PATH=/run/wrappers/bin:/home/${username}/.local/share/flatpak/exports/bin:/var/lib/flatpak/exports/bin:/home/${username}/.nix-profile/bin:/etc/profiles/per-user/${username}/bin:/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin";
        Restart = "on-failure";
        RestartSec = "5s";
      };
    };

    systemd.user.services.steam = {
      enable = true;
      description = "Steam game launcher";
      serviceConfig = {
        ExecStart = "${pkgs.gamescope}/bin/gamescope -e -w 1920 -h 1080 -- ${steam}/bin/steam -steamos -gamepadui -nointro";
        Restart = "on-failure";
        RestartSec = "5s";
      };
    };

    # Requires to simulate input
    boot.kernelModules = [ "uinput" ];
    services.udev.extraRules = ''
      KERNEL=="uinput", SUBSYSTEM=="misc", OPTIONS+="static_node=uinput", TAG+="uaccess"
    '';

    environment.systemPackages = with pkgs; [ sunshine ];
    networking.firewall.allowedTCPPortRanges = [
      {
        from = 47984;
        to = 48010;
      }
    ];
    networking.firewall.allowedUDPPortRanges = [
      {
        from = 47998;
        to = 48010;
      }
    ];
    environment.persistence."/persist".users.${username} = {
      directories = [ ".config/sunshine/credentials" ];
      files = [
        ".config/sunshine/sunshine_state.json"
        ".config/sunshine/sunshine.log"
      ];
    };
  };
}
