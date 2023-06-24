# http://localpost.hsnet.nixlap.top:11451
{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.modules.services.ollama-passthrough;
in
{
  options = {
    modules.services.ollama-passthrough = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
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
    networking.firewall.allowedTCPPorts = [ 7154 ];
  };
}
