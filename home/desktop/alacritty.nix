{
  lib,
  config,
  inputs,
  ...
}: {
  programs.alacritty = {
    enable = false;
    settings = {
      font = {
        normal = lib.mkForce {
          family = "Spleen";
          style = "Regular";
        };
        bold = lib.mkForce {
          family = "Spleen";
        };
        italic = lib.mkForce {
          family = "Spleen";
        };
        # size in pt
        size = 9;
      };
      window = {
        opacity = 0.8;
        padding = {
          x = 20;
          y = 20;
        };
      };
      env = {
        TERM = "xterm-256color";
      };
      import = [
        "~/.config/alacritty/catppuccin/catppuccin-mocha.yml"
      ];
    };
  };
  xdg.configFile."alacritty/catppuccin" = lib.mkIf config.programs.alacritty.enable {
    source = inputs.catppuccin-alacritty.outPath;
  };
}
