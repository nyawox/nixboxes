{
  inputs,
  pkgs,
  ...
}: {
  programs.wezterm = {
    enable = true;
    package = inputs.nixpkgs-f2k.packages.${pkgs.system}.wezterm-git;
    # https://github.com/wez/wezterm/issues/4483
    extraConfig = ''
      return {
        font = wezterm.font("Spleen"),
        font_size = 9,
        color_scheme = "Catppuccin Mocha",
        use_fancy_tab_bar = false,
        show_new_tab_button_in_tab_bar = false,
        window_padding = {
          left = 15,
          right = 15,
          top = 15,
          bottom = 10,
        }
      }
    '';
  };
}
