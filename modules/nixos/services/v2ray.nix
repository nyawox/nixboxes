{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.services.v2ray;
  generateOutbound = tag: sendThrough: {
    protocol = "socks";
    sendThrough = sendThrough;
    tag = tag;
    settings = {
      servers = [
        {
          address = "127.0.0.1";
          port = 9050;
        }
      ];
    };
  };

  outbounds = lib.genList (i: generateOutbound "tor-${toString (i + 1)}" "127.0.0.${toString (i + 1)}") 50;

  v2rayConfig = {
    log = {
      loglevel = "warning";
    };

    inbounds = [
      {
        port = 9052;
        listen = "127.0.0.1";
        protocol = "http";
        sniffing = {
          enabled = true;
          destOverride = ["http" "tls"];
        };
      }
    ];

    outbounds = outbounds;

    routing = {
      rules = [
        {
          type = "field";
          network = "tcp";
          balancerTag = "balancer";
        }
      ];

      balancers = [
        {
          tag = "balancer";
          selector = ["tor-"];
          strategy = {
            type = "random";
          };
        }
      ];
    };
  };
in {
  options = {
    modules.services.v2ray = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };
  config = mkIf cfg.enable {
    services.v2ray = {
      enable = true;
      config = v2rayConfig;
    };
  };
}
