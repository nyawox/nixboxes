{
  config,
  lib,
  pkgs,
  username,
  ...
}:
with lib; let
  cfg = config.modules.services.tailscale;
  loginserver = "https://headscale.nixhome.shop";
  authkey = "857c04acb562d52051aad7eb6d9b0851419163beee876328";
in {
  options = {
    modules.services.tailscale = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };
  config = mkIf cfg.enable {
    services.tailscale = {
      enable = true;
      permitCertUid = username;
    };
    networking.firewall = {
      checkReversePath = "loose";
      trustedInterfaces = ["tailscale0"];
      allowedUDPPorts = [config.services.tailscale.port];
    };
    environment.persistence."/persist".directories = mkIf config.modules.sysconf.impermanence.enable ["/var/lib/tailscale"];

    # create a oneshot job to authenticate to Tailscale
    systemd.services.tailscale-autoconnect = {
      description = "Automatic connection to Tailscale";

      # make sure tailscale is running before trying to connect to tailscale
      after = ["network-pre.target" "tailscale.service"];
      wants = ["network-pre.target" "tailscale.service"];
      wantedBy = ["multi-user.target"];

      # set this service as a oneshot job
      serviceConfig.Type = "oneshot";

      # have the job run this shell script
      script = with pkgs; ''
        # wait for tailscaled to settle
        sleep 2

        # check if we are already authenticated to tailscale
        status="$(${tailscale}/bin/tailscale status -json | ${jq}/bin/jq -r .BackendState)"
        if [ $status = "Running" ]; then # if so, then do nothing
          exit 0
        fi

        # otherwise authenticate with tailscale
        ${tailscale}/bin/tailscale up --login-server ${loginserver} --auth-key ${authkey}
        # don't forget to replace auth key each time
      '';
    };
  };
}
