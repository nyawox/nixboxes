{
  programs.ssh = {
    enable = true;
    compression = true;
    controlMaster = "auto";
    extraConfig =
      /*
      sshclientconfig
      */
      ''
        ServerAliveInterval 15
        ServerAliveCountMax 3
        ConnectionAttempts 3
        RekeyLimit default 600
        VisualHostKey yes
        UpdateHostKeys yes
      '';
    matchBlocks = {
      "phone" = {
        hostname = "localmost";
        user = "root";
      };
      "ghostluks" = {
        hostname = "64.112.124.245";
        user = "root";
        port = 42420;
        checkHostIP = false;
        extraOptions = {
          RequestTTY = "force";
          RemoteCommand = "systemctl default";
        };
      };
      "postluks" = {
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
