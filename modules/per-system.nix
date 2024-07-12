{inputs, ...}: {
  perSystem = {
    pkgs,
    system,
    config,
    ...
  }: {
    _module.args.pkgs = import inputs.nixpkgs {
      inherit system;
      overlays = [
        inputs.nur.overlay
        inputs.emacs-overlay.overlay
        inputs.berberman.overlays.default
        (final: prev: import ../pkgs final prev)
      ];
    };
    treefmt = {
      programs = {
        alejandra.enable = true;
        deadnix.enable = true;
        statix.enable = true;
        prettier.enable = true;
        beautysh.enable = true;
        yamlfmt.enable = true;
      };
      settings.formatter = {
        beautysh.includes = [
          "remoteinstall"
          "localinstall"
        ];
      };
      flakeFormatter = true;
      projectRootFile = "flake.nix";
    };
    # Not to be confused with capital S "devShells"
    devshells.default = {
      packages = with pkgs; [
        config.treefmt.build.wrapper
        deploy-rs
        nvfetcher
        ssh-to-age
        alejandra
        deadnix
        statix
      ];
      #TODO Make a better interface, preferably TUI to manage systems
      commands = [
        {
          name = "cleanup";
          help = "Clean & optimize nix store. it can take a long time";
          command = "sudo -- sh -c 'nix-collect-garbage -d; nix-store --optimize'";
          category = "cleanup";
        }
        {
          name = "format";
          help = "Format nix codes";
          command = "nix fmt";
          category = "misc";
        }
        {
          name = "install-sops-key";
          help = "Install sops age key on .config/sops to decrypt secrets";
          command = "mkdir -p /home/$USER/.config/sops/age; sudo ssh-to-age -private-key -i /etc/ssh/id_ed25519_age -o /home/$USER/.config/sops/age/keys.txt";
          category = "misc";
        }
        {
          name = "update";
          help = "Update all flake inputs and commit lock file";
          command = "nix flake update --commit-lock-file";
        }
        {
          name = "isobuild";
          help = "Build iso";
          command = "nix build .#nixosConfigurations.iso.config.system.build.isoImage";
        }
        {
          name = "rebuild";
          help = "Rebuild current system and switch";
          command = "sudo nixos-rebuild switch --flake .#";
        }
        {
          name = "rebuild-boot";
          help = "Rebuild current system and make it the boot default without activating";
          command = "sudo nixos-rebuild boot --flake .#";
        }
        {
          name = "iso";
          help = "Build NixOS minimal install ISO for amd64";
          command = "nix build .#nixosConfigurations.iso.config.system.build.isoImage";
        }
        {
          name = "isoarm";
          help = "Build NixOS minimal install ISO for aarch64";
          command = "nix build .#nixosConfigurations.isoarm.config.system.build.isoImage";
        }
      ];
    };
  };
}
