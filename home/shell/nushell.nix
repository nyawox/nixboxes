{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  nuScripts = "${pkgs.nu_scripts}/share/nu_scripts";

  mkCompletions = names:
    concatStringsSep "\n" (map (name: "source \"${nuScripts}/custom-completions/${name}/${name}-completions.nu\"") names);
in {
  options = {
    modules.shell.nushell = {
      enable = mkOption {
        type = types.bool;
        default = true;
      };
    };
  };
  config = mkIf config.modules.shell.nushell.enable {
    programs.nushell = {
      enable = true;
      extraConfig =
        /*
        nu
        */
        ''
          def _aichat_nushell [] {
            let _prev = (commandline)
            if ($_prev != "") {
              print '⌛'
              commandline edit -r (aichat -e $_prev)
            }
          }

          def lsd [] { ls | sort-by type name -i | grid -c }

          ${mkCompletions [
            "git"
            "adb"
            "curl"
            "cargo"
            "cargo-make"
            "btm"
            "bat"
            "zellij"
            "tar"
            "rustup"
            "rg"
            "npm"
            "nix"
            "man"
            "make"
            "less"
            "just"
            "docker"
            "fastboot"
          ]}

          source "${nuScripts}/modules/nix/nix.nu"
          source "${nuScripts}/modules/jc/mod.nu"
        '';
      extraEnv =
        /*
        nu
        */
        ''
          use "${nuScripts}/themes/nu-themes/catppuccin-mocha.nu"
          let carapace_completer = {|spans|
            carapace $spans.0 nushell $spans | from json
          }

          $env.config = {
            show_banner: false,
            color_config: (catppuccin-mocha),
            completions: {
              case_sensitive: false,
              quick: true,
              partial: true,
              algorithm: "fuzzy",
              external: {
                enable: true,
                max_results: 100,
                completer: $carapace_completer
              }
            },
            keybindings: [
              {
                name: aichat_integration,
                modifier: control,
                keycode: char_l,
                mode: [emacs, vi_insert],
                event:[
                  {
                    send: executehostcommand,
                    cmd: "_aichat_nushell"
                  }
                ]
              }
            ],
            table: {
              mode: rounded
            }
          }
          $env.LS_COLORS = (${lib.getExe pkgs.vivid} generate catppuccin-mocha)
        '';
      shellAliases = {
        vi = "hx";
        vim = "hx";
        nano = "hx";
        nix-prefetch-github = "nix-prefetch-github --nix";
        ll = "ls -l";
        c = "clear";
        do = "sudo";
        lix = "nix";
        writeusb = "sudo dd bs=4M oflag=sync status=progress";
      };
    };
  };
}
