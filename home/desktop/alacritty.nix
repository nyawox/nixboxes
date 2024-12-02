{
  lib,
  config,
  inputs,
  ...
}:
with lib;
let
  cfg = config.modules.desktop.alacritty;
in
{
  options = {
    modules.desktop.alacritty = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };
  config = mkIf cfg.enable {
    programs.alacritty = {
      enable = true;
      settings = {
        font = {
          normal = mkForce {
            family = "Spleen";
            style = "Regular";
          };
          bold = mkForce { family = "Spleen"; };
          italic = mkForce { family = "Spleen"; };
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
        import = [ "~/.config/alacritty/catppuccin/catppuccin-mocha.yml" ];
      };
    };
    xdg.configFile."alacritty/catppuccin" = mkIf config.programs.alacritty.enable {
      source = inputs.catppuccin-alacritty.outPath;
    };
  };
}
