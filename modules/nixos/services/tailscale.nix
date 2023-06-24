{
  config,
  lib,
  username,
  inputs,
  ...
}:
with lib;
let
  cfg = config.modules.services.tailscale;
  loginserver = "https://hs.nixlap.top";
in
{
  options = {
    modules.services.tailscale = {
      enable = mkEnableOption "Tailscale";
      notifier = mkEnableOption "Taildrop Notifier";
      setFlags = mkOption {
        type = types.listOf types.str;
        default = [ ];
      };
      upFlags = mkOption {
        type = types.listOf types.str;
        default = [ ];
      };
    };
  };
  imports = [ inputs.taildrop-notifier.nixosModules.taildrop-notifier ];
  config = mkIf cfg.enable (mkMerge [
    {
      services.tailscale = {
        enable = true;
        permitCertUid = username;
        authKeyFile = "/run/secrets/tailscale_preauthkey"; # auto connect tailscale
        authKeyParameters = {
          preauthorized = true;
          baseURL = loginserver;
        };
        extraSetFlags = [
          "--operator=${username}"
        ] ++ cfg.setFlags;
        extraUpFlags = cfg.upFlags;
      };
      services.taildrop-notifier = mkIf cfg.notifier {
        enable = true;
        user = username;
      };
      systemd.services.taildrop-notifier.serviceConfig.PrivateTmp = true;
      networking.firewall = {
        checkReversePath = "loose";
        trustedInterfaces = [ "tailscale0" ];
        allowedUDPPorts = [ config.services.tailscale.port ];
      };
      environment.persistence."/persist".directories = mkIf config.modules.sysconf.impermanence.enable [
        "/var/lib/tailscale"
      ];
      sops.secrets."tailscale_preauthkey" = {
        sopsFile = ../../../secrets/tailscale_preauthkey.psk;
        format = "binary";
      };
    }
    (mkIf (config.networking.hostName == "localghost") {
      services.tailscale.extraUpFlags = [ "--advertise-tags=tag:nyaa-servers,tag:caddy,tag:llm-access" ];
    })
    (mkIf (config.networking.hostName == "localpost") {
      services.tailscale.extraUpFlags = [
        "--advertise-tags=tag:nyaa-servers,tag:adguard-home,tag:llm-access"
      ];
    })
    (mkIf (config.networking.hostName == "lolcathost") {
      services.tailscale.extraUpFlags = [
        "--advertise-tags=tag:nyaa-desktops,tag:nyaa-exitnode-clients,tag:llm-access,tag:llm-servers"
      ];
    })
    (mkIf (config.networking.hostName == "localtoast") {
      services.tailscale.extraUpFlags = [ "--advertise-tags=tag:nyaa-laptops,tag:adguard-home" ];
    })
  ]);
}
