{
  programs.broot = {
    enable = false;
    settings = {
      modal = true;
      imports = [
        {
          luma = ["dark" "unknown"];
          file = "skins/catppuccin-mocha.hjson";
        }
      ];
    };
  };
}
