{
  config,
  lib,
  pkgs,
  username,
  ...
}:
with lib; let
  cfg = config.modules.virtualisation.waydroid;
in {
  options = {
    modules.virtualisation.waydroid = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };
  config = mkIf cfg.enable {
    virtualisation.waydroid.enable = true;
    environment = {
      systemPackages = [
        pkgs.wl-clipboard # clipboard sharing
      ];

      etc."gbinder.d/waydroid.conf".source = mkForce (
        pkgs.writeText "waydroid.conf" ''
          [Protocol]
          /dev/binder = aidl3
          /dev/vndbinder = aidl3
          /dev/hwbinder = hidl

          [ServiceManager]
          /dev/binder = aidl3
          /dev/vndbinder = aidl3
          /dev/hwbinder = hidl

          [General]
          ApiLevel = 30
        ''
      );
      persistence."/persist".directories = mkIf config.modules.sysconf.impermanence.enable [
        "/var/lib/waydroid"
        {
          directory = "/var/lib/lxc";
          user = "root";
          group = "root";
          mode = "756";
        }
      ];
      persistence."/persist".users."${username}".directories =
        mkIf config.modules.sysconf.impermanence.enable
        [".local/share/waydroid"];
    };
  };
}
