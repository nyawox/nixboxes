{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:
with lib; let
  cfg = config.modules.shell.fish;
in {
  options = {
    modules.shell.fish = {
      enable = mkOption {
        type = types.bool;
        default = true;
      };
    };
  };
  config = mkIf cfg.enable {
    programs.fish = {
      enable = true;
      shellInit =
        /*
        fish
        */
        ''
          set fish_greeting
          fish_config theme choose "Catppuccin Mocha"
          fish_vi_key_bindings
        '';
      interactiveShellInit =
        /*
        fish
        */
        ''
          # bind -M insert \b backward-kill-word # ctrl-backspace
          # bind -M insert \ch backward-kill-word
        '';
      plugins = [
        {
          name = "autopair";
          src = inputs.fish-autopair.outPath;
        }
        {
          name = "fish-abbreviation-tips";
          src = inputs.fish-abbreviation-tips.outPath;
        }
        # colorized command output
        {
          name = "grc";
          inherit (pkgs.fishPlugins.grc) src;
        }
      ];
      shellAliases = {
        # quick cd
        ".." = "cd ..";
        "..." = "cd ../..";
        "...." = "cd ../../..";
        "....." = "cd ../../../..";

        # nix
        nix-prefetch-github = "nix-prefetch-github --nix";

        # clear
        c = "clear";

        # sudo
        do = "sudo";

        # lix
        lix = "nix";

        writeusb = "sudo dd bs=4M oflag=sync status=progress";
      };
    };
    xdg.configFile."fish/themes".source = inputs.catppuccin-fish.outPath + "/themes";

    home.packages = with pkgs; [grc];
  };
}
