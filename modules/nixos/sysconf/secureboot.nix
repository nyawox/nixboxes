{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
with lib; let
  cfg = config.modules.sysconf.secureboot;
in {
  imports = [
    inputs.lanzaboote.nixosModules.lanzaboote
  ];
  options = {
    modules.sysconf.secureboot = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Enable secureboot
        '';
      };
    };
  };
  config = mkIf cfg.enable {
    boot = {
      bootspec.enable = true;
      # Lanzaboote currently replaces the systemd-boot module.
      # This setting is usually set to true in configuration.nix
      # generated at installation time. So we force it to false
      # for now.
      loader.systemd-boot.enable = mkForce false;
      #loader.systemd-boot.enable = true;

      lanzaboote = {
        enable = true;
        # enrollKeys = true;
        configurationLimit = mkDefault 15;
        pkiBundle = "/persist/etc/secureboot";
      };
    };

    environment.systemPackages = [
      # For debugging and troubleshooting Secure Boot.
      pkgs.sbctl
    ];

    environment.persistence."/persist".directories = mkIf config.modules.sysconf.impermanence.enable ["/etc/secureboot"];
  };
}
