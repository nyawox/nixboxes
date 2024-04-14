{
  pkgs,
  inputs,
  ...
}: {
  programs.helix = {
    enable = true;
    package = inputs.helix.packages.${pkgs.system}.helix;
    defaultEditor = true;
    settings = {
      theme = "catppuccin_mocha_transparent";
      editor = {
        bufferline = "multiple"; # Show currently open buffers when multiple exists
        true-color = true;
        color-modes = true;
        line-number = "relative";
        cursor-shape = {
          normal = "block";
          insert = "bar";
          select = "underline";
        };
        lsp = {
          auto-signature-help = false;
          display-messages = true;
        };
        indent-guides = {
          character = ":";
          render = true;
        };
        statusline = {
          left = ["mode" "spinner" "version-control" "file-name"];
        };
      };
      keys.normal = {
        ";" = "command_mode"; # Replace : with ;
        space = {
          space = "file_picker";
        };
      };
      keys.insert = {
        # "C-h" = "delete_word_backward"; # Ctrl-bspc
      };
    };
    languages = {
      language = [
        {
          name = "nix";
          auto-format = true;
          formatter.command = "${pkgs.alejandra}/bin/alejandra";
        }
      ];
    };
    themes = {
      catppuccin_mocha_transparent = {
        "inherits" = "catppuccin_mocha";
        "ui.background" = {};
      };
    };
  };
}
