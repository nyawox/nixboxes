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
        space.space = "file_picker";
        ";" = "command_mode"; # Replace : with ;
        space.h.o = ":run-shell-command zellij run -fc -- yazi --chooser-file /tmp/yazi-chooser-file";
        space.h.u = [":new" ":insert-output cat /tmp/yazi-chooser-file" "split_selection_on_newline" "goto_file" "goto_last_modification" "goto_last_modified_file" ":buffer-close!"];
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
