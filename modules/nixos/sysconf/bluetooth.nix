{
  config,
  lib,
  hostname,
  ...
}:
with lib;
let
  cfg = config.modules.sysconf.bluetooth;
in
{
  options = {
    modules.sysconf.bluetooth = {
      enable = mkOption {
        type = types.bool;
        default = true;
      };
      blueman = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };
  config = mkIf cfg.enable {
    services.blueman.enable = mkIf cfg.blueman true;
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings = {
        General = {
          Experimental = true;
          # uncomment this to allow pairing Airpods then restart the bluetooth stack sudo systemctl restart bluetooth
          # only required at initial pairing
          # ControllerMode = "bredr";
          #
          # Speaker icon
          Class = "0x040414";
          Name = hostname;
          DiscoverableTimeout = 30;
          PairableTimeout = 30;
          MaxControllers = 1;
          TemporaryTimeout = 0;
        };
        Policy = {
          Privacy = "network/on";
        };
      };
    };
    # Make sure to trust the device immediately when using pipewire as bluetooth speaker
    #
    # Save bluetooth settings
    environment.persistence."/persist".directories = mkIf config.modules.sysconf.impermanence.enable [
      "/var/lib/bluetooth"
    ];
  };
}
