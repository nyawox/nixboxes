{
  config,
  lib,
  pkgs,
  username,
  ...
}:
with lib; let
  cfg = config.modules.services.tailscale;
  loginserver = "https://hs.nixlap.top";
  taildrop-dir = "/home/${username}/Downloads";
in {
  options = {
    modules.services.tailscale = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
      setFlags = mkOption {
        type = types.listOf types.str;
        default = [];
      };
      upFlags = mkOption {
        type = types.listOf types.str;
        default = [];
      };
    };
  };
  config = mkIf cfg.enable {
    services.tailscale = {
      enable = true;
      permitCertUid = username;
      authKeyFile = "/run/secrets/tailscale_preauthkey"; # auto connect tailscale
      authKeyParameters = {
        preauthorized = true;
        baseURL = loginserver;
      };
      extraSetFlags =
        [
          "--operator=${username}"
        ]
        ++ cfg.setFlags;
      extraUpFlags = cfg.upFlags;
    };
    systemd.user.services.taildrop = {
      enable = true;
      description = "Automatically save TailDrop files, just like AirDrop";
      after = ["network.target"];
      wantedBy = ["default.target"];
      script = "${getExe pkgs.tailscale} file get --conflict rename --loop --verbose ${taildrop-dir}";
    };
    networking.firewall = {
      checkReversePath = "loose";
      trustedInterfaces = ["tailscale0"];
      allowedUDPPorts = [config.services.tailscale.port];
    };
    environment.persistence."/persist".directories = mkIf config.modules.sysconf.impermanence.enable [
      "/var/lib/tailscale"
    ];
    sops.secrets."tailscale_preauthkey" = {
      sopsFile = ../../../secrets/tailscale_preauthkey.psk;
      format = "binary";
    };
  };
}
