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
    };
  };
}
