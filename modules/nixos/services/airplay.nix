{
  config,
  lib,
  pkgs,
  username,
  ...
}:
with lib;
let
  cfg = config.modules.services.airplay;
in
{
  options = {
    modules.services.airplay = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
      framerate = mkOption {
        type = types.int;
        default = 60;
      };
    };
  };
  config = mkIf cfg.enable {
    systemd.user.services.airplay = {
      enable = true;
      description = "AirPlay";
      wantedBy = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ]; # this must be set to ensure the service to only be valid whilst the session is active
      wants = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];

      serviceConfig = {
        # without unbuffer the logs are only printed when stopping service
        ExecStart = "${pkgs.expect}/bin/unbuffer ${getExe pkgs.uxplay} -n ${config.networking.hostName} -reg /home/${username}/.config/.uxplay.register -fps ${builtins.toString cfg.framerate}";
        Environment = "UXPLAYRC=/etc/uxplayrc";
        Restart = "on-failure";
        RestartSec = "5s";
      };
    };
    networking.firewall.allowedTCPPorts = [
      15244
      15245
      15246
    ];
    networking.firewall.allowedUDPPorts = [
      5353 # mDNS queries
      15244
      15245
      15246
    ];
    environment = {
      systemPackages = [ pkgs.uxplay ];
      shellAliases = {
        airplay = "journalctl --user -xfeu airplay.service";
      };
      persistence."/persist".users."${username}".files = mkIf config.modules.sysconf.impermanence.enable [
        ".config/.uxplay.register"
      ];
      etc."uxplayrc".text =
        # conf
        ''
          p 15244
          nh
          pin
          fs
        '';
    };
  };
}
