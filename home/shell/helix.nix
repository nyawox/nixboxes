{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:
with lib;
let
  cfg = config.modules.shell.helix;
  tree-sitter-kdl = pkgs.tree-sitter.buildGrammar {
    language = "kdl";
    version = "git";
    src = inputs.tree-sitter-kdl;
  };
in
{
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
    modules.shell = {
      zellij.enable = mkIf cfg.ide true;
      yazi.enable = mkIf cfg.ide true;
      magit.enable = mkIf cfg.ide true;
    };
    programs.helix = {
      enable = true;
      extraPackages = with pkgs; [
        markdown-oxide # markdown language server
        inputs.latest.legacyPackages.${pkgs.system}.nixfmt-rfc-style
        tree-sitter-kdl
        lsp-ai
        python3Packages.python-lsp-server
        rust-analyzer
      ];
      package = inputs.helix.packages.${pkgs.system}.helix;
      defaultEditor = true;
      settings = {
        theme = "catppuccin_mocha_transparent";
        editor = {
          auto-completion = true;
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
            auto-signature-help = true;
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
              "selections"
              "register"
              "position"
            ];
            center = [
              "read-only-indicator"
              "file-name"
              "file-modification-indicator"
            ];
            right = [
              "diagnostics"
              "file-encoding"
              "version-control"
            ];
            separator = "│";
          };
        };
        keys.normal = {
          ";" = "command_mode"; # Replace : with ;
          space = {
            space = "file_picker";
            n = mkIf cfg.ide ":sh zellij action focus-next-pane"; # focus in file tree
            o = mkIf cfg.ide {
              g = ":sh zellij run --name Git -fc -- bash -c \"TERM=xterm-direct emacsclient -nw --eval '(magit-status)'\""; # open magit in floating pane
              t = ":sh zellij action new-pane -c -d down -- bash -c \"for _ in {1..6}; do zellij action resize decrease up; done; nu\"";
            };
          };
        };
        keys.insert = {
          # "C-h" = "delete_word_backward"; # Ctrl-bspc
          "C-x" = "no_op";
          "C-l" = "completion"; # mnemonic for lsp
        };
      };
      languages = {
        language = [
          {
            name = "python";
            language-servers = [
              "pylsp"
              "lsp-ai"
            ];
          }
          {
            name = "nix";
            auto-format = true;
            language-servers = [
              "nixd"
              "lsp-ai"
            ];
            formatter.command = "${getExe inputs.latest.legacyPackages.${pkgs.system}.nixfmt-rfc-style}";
          }
          {
            name = "typescript";
            language-servers = [
              "typescript"
              "lsp-ai"
            ];
          }
          {
            name = "javascript";
            language-servers = [
              "typescript"
              "lsp-ai"
            ];
          }
          {
            name = "rust";
            auto-format = true;
            language-servers = [
              "rust-analyzer"
              "lsp-ai"
            ];
            formatter.command = "rustfmt";
          }
          {
            name = "kdl";
            scope = "source.kdl";
            injection-regex = "kdl";
            file-types = [ "kdl" ];
            roots = [ ];
            comment-token = "//";
            indent = {
              tab-width = 2;
              unit = "  ";
            };
          }
        ];
        language-server.nixd.command = "${getExe pkgs.nixd}";
        language-server.lsp-ai = {
          command = "${getExe pkgs.lsp-ai}";
          config = {
            memory = {
              file_store = { };
            };
            models = {
              qwen25coder = {
                type = "ollama";
                chat_endpoint = "http://lolcathost.hsnet.nixlap.top:11434/api/chat";
                generate_endpoint = "http://lolcathost.hsnet.nixlap.top:11434/api/generate";
                model = "qwen2.5-coder:14b-instruct-q4_K_M";
              };
            };
            completion = {
              model = "qwen25coder";
              parameters = {
                max_context = 8192;
                options = {
                  temperature = -1;
                  num_predict = 2048;
                };
                fim = {
                  start = "<｜fim▁begin｜>";
                  middle = "<｜fim▁hole｜>";
                  end = "<｜fim▁end｜>";
                };
              };
            };
          };
        };
      };
      themes = {
        catppuccin_mocha_transparent = {
          "inherits" = "catppuccin_mocha";
          "ui.background" = { };
        };
      };
    };
  };
}
