{
  inputs,
  pkgs,
  ...
}: {
  programs.wezterm = {
    enable = false; # migrated to foot
    package = inputs.nixpkgs-f2k.packages.${pkgs.system}.wezterm-git;
    # disable wayland temporarily
    # https://github.com/wez/wezterm/issues/5103
    extraConfig = ''
      return {
        enable_wayland = false
        font = wezterm.font("Spleen"),
        font_size = 9,
        color_scheme = "Catppuccin Mocha",
        use_fancy_tab_bar = false,
        tab_max_width = 25,
        show_new_tab_button_in_tab_bar = false,
        hide_tab_bar_if_only_one_tab = true,
        skip_close_confirmation_for_processes_named = {
          'bash',
          'sh',
          'zsh',
          'fish',
          'tmux',
          'zellij',
          'nu',
          'cmd.exe',
          'pwsh.exe',
          'powershell.exe',
        },
        window_padding = {
          left = 15,
          right = 15,
          top = 15,
          bottom = 10,
        },
        keys = {
        { key = 'Backspace', mods = 'CTRL', action = wezterm.action.SendKey {key = 'w', mods = 'CTRL'}, },
        }
      }
    '';
  };
}
