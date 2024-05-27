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
in
{
  options = {
    modules.shell.helix = {
      enable = mkOption {
        type = types.bool;
        default = true;
      };
    };
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      markdown-oxide # markdown language server
    ];
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
            formatter.command = "${pkgs.nixfmt-rfc-style}/bin/nixfmt";
          }
        ];
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
