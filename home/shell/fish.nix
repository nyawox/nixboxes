{pkgs, ...}: {
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
        src = pkgs.fetchFromGitHub {
          owner = "jorgebucaran";
          repo = "autopair.fish";
          rev = "4d1752ff5b39819ab58d7337c69220342e9de0e2";
          hash = "sha256-qt3t1iKRRNuiLWiVoiAYOu+9E7jsyECyIqZJ/oRIT1A=";
        };
      }
      {
        name = "fish-abbreviation-tips";
        src = pkgs.fetchFromGitHub {
          owner = "gazorby";
          repo = "fish-abbreviation-tips";
          rev = "8ed76a62bb044ba4ad8e3e6832640178880df485";
          hash = "sha256-F1t81VliD+v6WEWqj1c1ehFBXzqLyumx5vV46s/FZRU=";
        };
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

      # windows vm
      winstart = "sudo systemctl start podman-windows";
      winstop = "sudo systemctl stop podman-windows";
      winrestart = "sudo systemctl restart podman-windows";
      winstatus = "systemctl status podman-windows";
      winlog = "journalctl -feu podman-windows";
      winlogs = "journalctl -xeu podman-windows";
      winview = "xdg-open http://127.0.0.1:8006/";
      winrdp = "remmina -c rdp://docker@127.0.0.1:3389";

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
  xdg.configFile."fish/themes".source =
    pkgs.fetchFromGitHub
    {
      owner = "catppuccin";
      repo = "fish";
      rev = "b90966686068b5ebc9f80e5b90fdf8c02ee7a0ba";
      sha256 = "wQlYQyqklU/79K2OXRZXg5LvuIugK7vhHgpahpLFaOw=";
    }
    + "/themes";

  home.packages = with pkgs; [
    grc
  ];
}
