{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:
with lib; let
  cfg = config.modules.shell.helix;
  tree-sitter-kdl = pkgs.tree-sitter.buildGrammar {
    language = "kdl";
    version = "git";
    src = inputs.tree-sitter-kdl;
  };
in {
  options = {
    modules.shell.helix = {
      enable = mkOption {
        type = types.bool;
        default = true;
      };
      ide = mkOption {
        type = types.bool;
        default = true;
      };
    };
  };
  config = mkIf cfg.enable {
    modules.shell.zellij.enable = mkIf cfg.ide true;
    modules.shell.yazi.enable = mkIf cfg.ide true;
    programs.helix = {
      enable = true;
      extraPackages = with pkgs; [
        markdown-oxide # markdown language server
        alejandra
        nil
        tree-sitter-kdl
      ];
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
            character = "│";
            render = true;
          };
          statusline = {
            left = [
              "mode"
              "spinner"
              "version-control"
              "file-name"
            ];
          };
        };
        keys.normal = {
          ";" = "command_mode"; # Replace : with ;
          space = {
            space = "file_picker";
            n = mkIf cfg.ide ":sh zellij action focus-next-pane"; # focus in file tree
            o = mkIf cfg.ide {
              g = ":sh zellij run --name Git -fc -- bash -c \"TERM=xterm-direct emacsclient -nw --eval '(magit-status)'\""; # open magit in floating pane
              t = ":sh zellij action new-pane -c -d down -- bash -c \"for _ in {1..6}; do zellij action resize decrease up; done; fish\"";
            };
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
          {
            name = "kdl";
            scope = "source.kdl";
            injection-regex = "kdl";
            file-types = ["kdl"];
            roots = [];
            comment-token = "//";
            indent = {
              tab-width = 2;
              unit = "  ";
            };
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
  };
}
