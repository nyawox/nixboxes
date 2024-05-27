{
  pkgs,
  inputs,
  ...
}: {
  programs.fish = {
    enable = true;
    shellInit = ''
      set fish_greeting
      fish_config theme choose "Catppuccin Mocha"
      fish_vi_key_bindings
      # doom emacs path
      fish_add_path ~/.config/emacs/bin
      # FIXME: remove once https://github.com/helix-editor/helix/issues/10089 is fixed
      function hx
          command hx $argv
          printf '\033[0 q'
      end
    '';
    interactiveShellInit = ''
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

      # cat
      cat = "bat";

      ge = "gex";
      # git
      g = "git";
      gc = "git clone";

      # clear
      c = "clear";

      # sudo
      do = "sudo";

      # magit
      magit = "TERM=xterm-direct emacsclient -nw --eval '(magit-status)'";

      # lix
      lix = "nix";

      # run balena etcher
      etcher = "NIXPKGS_ALLOW_INSECURE=1 nix run nixpkgs#etcher --impure";

      writeusb = "sudo dd bs=4M oflag=sync status=progress";

      # fastfetch
      fetch = "fastfetch";

      # zoxide
      j = "cd"; # j is easier to press than z on my layout
      ji = "cdi";
    };
  };
  xdg.configFile."fish/themes".source = inputs.catppuccin-fish.outPath + "/themes";

  home.packages = with pkgs; [
    grc
  ];
}
