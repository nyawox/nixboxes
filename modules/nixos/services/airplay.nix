{
  config,
  lib,
  pkgs,
  username,
  ...
}:
with lib; let
  cfg = config.modules.services.airplay;
in {
  options = {
    modules.services.airplay = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.uxplay
    ];
    environment.shellAliases = {
      airplay = "journalctl --user -xfeu airplay.service";
    };
    systemd.user.services.airplay = {
      enable = true;
      description = "AirPlay";
      wantedBy = ["graphical-session.target"];
      serviceConfig = {
        ExecStart = "${pkgs.expect}/bin/unbuffer ${pkgs.uxplay}/bin/uxplay -n ${config.networking.hostName} -reg /home/${username}/.config/.uxplay.register";
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
    environment.etc."uxplayrc".text = ''
      p 15244
      nh
      pin
    '';
    environment.persistence."/persist".users."${username}".files = mkIf config.modules.sysconf.impermanence.enable [".config/.uxplay.register"];
  };
}
