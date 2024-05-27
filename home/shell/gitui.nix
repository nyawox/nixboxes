{inputs, ...}: {
  programs.gitui = {
    enable = true;
    theme = builtins.readFile "${inputs.catppuccin-gitui.outPath}/themes/catppuccin-mocha.ron";
  };
}
