{
  programs.ssh = {
    enable = true;
    compression = true;
    controlMaster = "auto";
    extraConfig = ''
      ServerAliveInterval 15
      ServerAliveCountMax 3
      ConnectionAttempts 3
      RekeyLimit default 600
      VisualHostKey yes
      UpdateHostKeys yes
    '';
    matchBlocks = {
      "phone" = {
        hostname = "192.168.0.129";
        user = "root";
      };
      "vultrluks" = {
        hostname = "149.28.98.185";
        user = "root";
        port = 42420;
        checkHostIP = false;
        extraOptions = {
          RequestTTY = "force";
          RemoteCommand = "systemctl default";
        };
      };
      "tomoyoluks" = {
        hostname = "64.112.124.245";
        user = "root";
        port = 42420;
        checkHostIP = false;
        extraOptions = {
          RequestTTY = "force";
          RemoteCommand = "systemctl default";
        };
      };
      "rockluks" = {
        hostname = "192.168.0.185";
        user = "root";
        port = 42420;
        checkHostIP = false;
        extraOptions = {
          RequestTTY = "force";
          RemoteCommand = "systemctl default";
        };
      };
      "router" = {
        hostname = "192.168.0.160";
        user = "root";
      };
      "routerhallway" = {
        hostname = "192.168.0.155";
        user = "root";
      };
      "ChidamaGakuen" = {
        hostname = "192.168.0.194";
        user = "hiyori";
        port = 22;
        checkHostIP = false;
      };
    };
  };
}
