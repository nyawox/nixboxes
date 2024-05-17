{pkgs, ...}: {
  programs.zathura = {
    enable = true;
    extraConfig = ''
      include catppuccin-mocha
    '';
  };

  xdg.configFile."zathura/catppuccin-mocha".source =
    pkgs.fetchFromGitHub {
      owner = "catppuccin";
      repo = "zathura";
      rev = "0adc53028d81bf047461bc61c43a484d11b15220";
      hash = "sha256-/vD/hOi6KcaGyAp6Az7jL5/tQSGRzIrf0oHjAJf4QbI=";
    }
    + "/src/catppuccin-mocha";
}
