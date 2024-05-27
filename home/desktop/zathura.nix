{inputs, ...}: {
  programs.zathura = {
    enable = true;
    extraConfig = ''
      include catppuccin-mocha
    '';
  };

  xdg.configFile."zathura/catppuccin-mocha".source = inputs.catppuccin-zathura.outPath + "/src/catppuccin-mocha";
}
