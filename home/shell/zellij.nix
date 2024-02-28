{
  programs.zellij = {
    enable = true;
    enableFishIntegration = false;
    settings = {
      theme = "catppuccin-mocha";
      default_layout = "compact";
      pane_frames = false;
      # ui = {
      #   pane_frames = {
      #     rounded_corners = true;
      #   };
      # };
    };
  };
}
