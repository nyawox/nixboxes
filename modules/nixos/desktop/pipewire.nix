{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.desktop.pipewire;
in {
  options = {
    modules.desktop.pipewire = {
      enable = mkOption {
        type = types.bool;
        default = true;
      };
    };
  };
  config = mkIf cfg.enable {
    # rtkit is optional but recommended
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      # If you want to use JACK applications, uncomment this
      #jack.enable = true;
    };
    environment.etc = {
      # Bluetooth
      "wireplumber/bluetooth.lua.d/51-bluez-config.lua".text = ''
        bluez_monitor.properties = {
          ["bluez5.enable-sbc-xq"] = true,
          ["bluez5.enable-msbc"] = true,
          ["bluez5.enable-hw-volume"] = true,
          ["bluez5.headset-roles"] = "[ hsp_hs hsp_ag hfp_hf hfp_ag ]"
               }
      '';

      # Low latency
      # "pipewire/pipewire.conf.d/92-low-latency.conf".text = ''
      #   context.properties = {
      #     default.clock.rate = 48000
      #     default.clock.quantum = 32
      #     default.clock.min-quantum = 32
      #     default.clock.max-quantum = 32
      #   }
      # '';
      # "pipewire/pipewire-pulse.d/92-low-latency.conf".source = json.generate "92-low-latency.conf" {
      #   context.modules = [
      #     {
      #       name = "libpipewire-module-protocol-pulse";
      #       args = {
      #         pulse.min.req = "32/48000";
      #         pulse.default.req = "32/48000";
      #         pulse.max.req = "32/48000";
      #         pulse.min.quantum = "32/48000";
      #         pulse.max.quantum = "32/48000";
      #       };
      #     }
      #   ];
      #   stream.properties = {
      #     node.latency = "32/48000";
      #     resample.quality = 1;
      #   };
      # };
    };
  };
}
