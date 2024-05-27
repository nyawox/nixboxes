{
  pkgs,
  inputs,
  ...
}: {
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
      ".doom.d/themes/catppuccin-theme.el".source = inputs.catppuccin-emacs.outPath + "/catppuccin-theme.el";
    };

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
