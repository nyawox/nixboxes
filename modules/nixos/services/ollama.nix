# https://nixpro64.nyaa.nixlap.top:11451
{
  config,
  lib,
  # username,
  # pkgs,
  ...
}:
with lib; let
  cfg = config.modules.services.ollama;
  # ipSubnet = "172.26.0.0/16";
in {
  options = {
    modules.services.ollama = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
      # port = mkOption {
      #   type = types.int;
      #   default = 11451;
      # };
    };
  };
  config = mkIf cfg.enable {
    # passthrough ollama port from local server
    services.frp = {
      enable = true;
      role = "server";
      settings = {
        common = {
          bind_port = 7154;
        };
      };
    };
    networking.firewall.allowedTCPPorts = [7154];

    # nixpkgs.config = {
    # cudaSupport = true;
    #   rocmSupport = true;
    #   rocmTargets = ["gfx900"];
    # };
    # virtualisation.arion.projects.ollama.settings = {
    #   project.name = "ollama";
    #   networks = {
    #     default = {
    #       name = "ollama";
    #       ipam = {
    #         config = [{subnet = ipSubnet;}];
    #       };
    #     };
    #   };

    #   services.ollama = {
    #     # out.service = {
    #     #   deploy.resources.reservations.devices = [
    #     #     {
    #     #       driver = "nvidia";
    #     #       count = 1;
    #     #       capabilities = ["gpu"];
    #     #     }
    #     #   ];
    #     # };
    #     service = {
    #       # image = "ollama/ollama:latest";
    #       image = "ollama/ollama:rocm";
    #       container_name = "ollama";
    #       devices = [
    #         "/dev/dri/card1"
    #         "/dev/kfd"
    #         "/dev/dri/renderD128"
    #       ];
    #       environment = {
    #         OLLAMA_ORIGINS = "*"; # allow requests from any origins
    #         HSA_OVERRIDE_GFX_VERSION = "10.3.0";
    #       };
    #       volumes = ["/home/${username}/ollama:/root/.ollama"];
    #       restart = "unless-stopped";
    #       ports = [
    #         "${builtins.toString cfg.port}:11434"
    #       ];
    #       labels."io.containers.autoupdate" = "registry";
    #     };
    #   };
    # };
    # systemd.services.arion-ollama = {
    #   wants = ["network-online.target"];
    #   after = ["network-online.target"];
    # };
    # networking = {
    #   nftables.enable = lib.mkForce false;
    #   firewall.extraCommands = ''
    #     iptables -A INPUT -p tcp --destination-port 53 -s ${ipSubnet} -j ACCEPT
    #     iptables -A INPUT -p udp --destination-port 53 -s ${ipSubnet} -j ACCEPT
    #   '';
    # };

    # environment.persistence."/persist" = mkIf config.modules.sysconf.impermanence.enable {
    #   users."${username}" = {
    #     directories = [
    #       "/ollama"
    #     ];
    #   };
    # };
  };
}
