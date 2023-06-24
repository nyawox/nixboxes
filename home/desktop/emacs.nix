{pkgs, ...}: {
  programs.emacs = {
    enable = true;
    package = pkgs.emacs29-pgtk;
    extraPackages = epkgs: [epkgs.vterm];
  };
  services.emacs.enable = true;
  home = {
    file = {
      ".doom.d" = {
        source = ./doom.d;
        recursive = true;
      };
      ".doom.d/themes/catppuccin-theme.el".source =
        pkgs.fetchFromGitHub
        {
          owner = "catppuccin";
          repo = "emacs";
          rev = "fa9e421b5e041217d4841bea27384faa194deff6";
          sha256 = "rUvY6yautK+5wvHy8oteGo4Lftip1h5He9ejADso0Ag=";
        }
        + "/catppuccin-theme.el";
    };
    sessionVariables."EDITOR" = "emacsclient -c";

    packages = with pkgs; [
      python3
      ripgrep
      # Formatter for nix code
      pkgs.alejandra
      # Language servers
      nil
      emmet-ls
      nodePackages.typescript-language-server
      haskell-language-server
      yaml-language-server
      nodePackages.bash-language-server
    ];
  };
}
