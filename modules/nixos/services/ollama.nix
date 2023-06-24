{
  config,
  lib,
  username,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.modules.services.ollama;
  ipSubnet = "172.26.0.0/16";
in
{
  options = {
    modules.services.ollama = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
      port = mkOption {
        type = types.int;
        default = 11434;
      };
      codingModel = mkOption {
        type = types.str;
        default = "hf.co/bartowski/Qwen2.5-Coder-14B-Instruct-GGUF:IQ4_XS"; # fits in vram
        description = ''
          Just an internal option to reference from other modules
        '';
      };
      chatModel = mkOption {
        type = types.str;
        default = "hf.co/bartowski/Qwen2.5-32B-Instruct-GGUF:Qwen2.5-32B-Instruct-IQ3_XS.gguf"; # fits in vram
        description = ''
          Just an internal option to reference from other modules
        '';
      };
    };
  };
  config = mkIf cfg.enable {
    # services.ollama = {
    #   enable = true;
    #   # loading larger model is broken < v0.3.14
    #   acceleration = "rocm";
    #   rocmOverrideGfx = "9.0.0";
    #   host = "[::]";
    #   environmentVariables = {
    #     HSA_ENABLE_SDMA = "0"; # !!!!!!!! WITHOUT THIS VARIABLE OLLAMA CRASHES, RESETS, AND LOCKS MY GPU !!!!!!
    #     OLLAMA_DEBUG = "true";
    #   };
    #   inherit (cfg) port;
    # };

    #### run container temporarily until nixpkgs#354969
    modules.virtualisation.arion.enable = mkForce true;
    virtualisation.arion.projects.ollama.settings = {
      project.name = "ollama";
      networks = {
        default = {
          name = "ollama";
          ipam = {
            config = [ { subnet = ipSubnet; } ];
          };
        };
      };
      services.ollama.service = {
        network_mode = "host";
        image = "ollama/ollama:rocm";
        environment = {
          HSA_ENABLE_SDMA = "0"; # !!!!!!!! WITHOUT THIS VARIABLE OLLAMA CRASHES, RESETS, AND LOCKS MY GPU !!!!!!
          HSA_OVERRIDE_GFX_VERSION = "9.0.0";
          OLLAMA_ORIGINS = "*";
          OLLAMA_DEBUG = "true";
        };
        ports = [ "${builtins.toString cfg.port}:11434" ];
        volumes = [ "/var/lib/private/ollama:/root/.ollama" ];
        devices = [
          "/dev/kfd"
          "/dev/dri/renderD128" # should be amdgpu
        ];
        restart = "unless-stopped";
        labels."io.containers.autoupdate" = "registry";
      };
    };
    systemd.services.arion-ollama = {
      wants = [ "network-online.target" ];
      after = [
        "network-online.target"
        "var-lib-ollama.mount"
      ];
    };
    networking = {
      nftables.enable = mkForce false;
      firewall.extraCommands =
        # bash
        ''
          iptables -A INPUT -p tcp --destination-port 53 -s ${ipSubnet} -j ACCEPT
          iptables -A INPUT -p udp --destination-port 53 -s ${ipSubnet} -j ACCEPT
        '';
    };
    ####

    users = {
      groups.ollama = { };
      users.ollama = {
        group = "ollama";
        isSystemUser = true;
      };
    };
    environment = {
      systemPackages = with pkgs; [
        rocmPackages.rocminfo
        rocmPackages.rocm-smi
        oterm
        ollama
      ];
      persistence."/persist".directories = mkIf config.modules.sysconf.impermanence.enable (singleton {
        directory = "/var/lib/private/ollama";
        user = "ollama";
        group = "ollama";
        mode = "750";
      });
      persistence."/persist".users.${username}.directories =
        mkIf config.modules.sysconf.impermanence.enable
          [
            ".ollama"
          ];
    };
    # systemd.services.ollama.after = ["var-lib-ollama.mount"];
  };
}
