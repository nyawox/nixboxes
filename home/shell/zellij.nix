{
  programs.zellij = {
    enable = true;
    enableFishIntegration = false;
    settings = {
      theme = "catppuccin-mocha";
      default_layout = "compact";
      pane_frames = false;
      keybinds = {
        unbind = "Ctrl h";
        move = {
          bind = {
            _args = ["Ctrl a"];
            SwitchToMode = "Normal";
          };
        };
      };
      # ui = {
      #   pane_frames = {
      #     rounded_corners = true;
      #   };
      # };
    };
  };
}
