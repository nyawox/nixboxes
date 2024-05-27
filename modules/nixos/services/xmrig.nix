{
  config,
  lib,
  hostname,
  ...
}:
with lib;
let
  cfg = config.modules.services.xmrig;
in
{
  options = {
    modules.services.xmrig = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };
  config = mkIf cfg.enable {
    services.xmrig = {
      enable = false;
      settings = {
        autosave = true;
        cpu = true;
        opencl = false;
        cuda = false;
        pools = [
          {
            url = "kr.zephyr.herominers.com:1123";
            user = "ZEPHYR3CscuZdJv2BMKuqzYNPq4iNcvKZexWb3UA1yx2X4fR4sFGT113bxNdPuMqy1EupxgYjX1QBMe9nzUA3uxd95KNd7DJkR14k";
            pass = hostname;
            algo = "rx/0";
            keepalive = true;
            tls = true;
          }
        ];
      };
    };
    # Don't automatically start xmrig
    systemd.services."xmrig".wantedBy = lib.mkForce [ ];
  };
}
