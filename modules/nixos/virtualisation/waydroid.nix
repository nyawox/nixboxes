# Add the following code to /var/lib/waydroid/waydroid.cfg
# ro.adb.secure=1
# ro.debuggable=0
# ro.build.selinux=1
# ro.build.tags=release-keys
# ro.product.build.tags=release-keys
# ro.vendor.build.tags=release-keys
# ro.odm.build.tags=release-keys
# then, run waydroid upgrade --offline  to regenerate waydroid_base.prop
# also make sure to chmod g-w o-w -R /var/lib/waydroid/overlay for good measure if you installed an overlay such as Widevine or Houdini.
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
