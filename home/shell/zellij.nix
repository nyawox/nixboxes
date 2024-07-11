{
  lib,
  config,
  inputs,
  username,
  ...
}:
with lib; let
  cfg = config.modules.shell.zellij;
in {
  options = {
    modules.shell.zellij = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };
  config = mkIf cfg.enable {
    programs.zellij = {
      enable = true;
      enableBashIntegration = false;
      enableFishIntegration = false;
      enableZshIntegration = false;
    };
    programs.nushell.shellAliases = {
      he = "zellij -s $'($env.PWD | path basename)-(random int)' -l /home/${username}/.config/zellij/layouts/helix.kdl";
    };

    xdg.configFile = {
      "zellij/config.kdl".text =
        builtins.readFile ./zellij/config.kdl
        + ''
          theme "catppuccin-mocha"
          on_force_close "quit"
          simplified_ui true
          pane_frames true
          ui {
            pane_frames {
              hide_session_name true
              rounded_corners true
            }
          }
        '';

      "zellij/yazi/yazi.toml".text =
        /*
        toml
        */
        ''
          [manager]
          ratio = [0, 4, 0]

          [opener]
          edit = [{ run = 'zellij edit "$1"', desc = "Open File in Helix" }]
        '';
      "zellij/yazi/theme.toml".source = inputs.catppuccin-yazi.outPath + "/themes/mocha.toml";
      "zellij/yazi/Catppuccin-mocha.tmTheme".source = inputs.catppuccin-bat.outPath + "/themes/Catppuccin Mocha.tmTheme";

      "zellij/yazi/init.lua".text =
        /*
        lua
        */
        ''
          function Status:render(area)
          	self.area = area

          	local line = ui.Line { self:percentage(), self:position() }
          	return {
          		ui.Paragraph(area, { line }):align(ui.Paragraph.CENTER),
          	}
          end
        '';

      "zellij/layouts/helix.kdl".source = ./zellij/helix.kdl;
      "zellij/layouts/helix.swap.kdl".source = ./zellij/helix.swap.kdl;
    };
  };
}
