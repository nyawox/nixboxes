{
  config,
  lib,
  pkgs,
  username,
  ...
}:
with lib; let
  cfg = config.modules.services.sunshine;
in {
  options = {
    modules.services.sunshine = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };
  config = mkIf cfg.enable {
    services.sunshine = {
      enable = true;
      capSysAdmin = true;
      openFirewall = true;
    };

    # Requires to simulate input
    boot.kernelModules = ["uinput"];
    services.udev.extraRules =
      /*
      rules
      */
      ''
        KERNEL=="uinput", SUBSYSTEM=="misc", OPTIONS+="static_node=uinput", TAG+="uaccess"
      '';

    environment.systemPackages = with pkgs; [sunshine];
    environment.persistence."/persist".users.${username} = {
      directories = [".config/sunshine/credentials"];
      files = [
        ".config/sunshine/sunshine_state.json"
        ".config/sunshine/sunshine.log"
      ];
    };
  };
}
