_: {
  programs.wezterm = {
    enable = true;
    extraConfig = ''
      return {
        font = wezterm.font("Spleen"),
        font_size = 12,
        color_scheme = "Catppuccin Mocha",
        use_fancy_tab_bar = false,
        show_new_tab_button_in_tab_bar = false,
        window_padding = {
          left = 20,
          right = 20,
          top = 20,
          bottom = 10,
        }
      }
    '';
  };
}
