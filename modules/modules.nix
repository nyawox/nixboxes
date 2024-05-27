{inputs, ...}: {
  flake = {
    nixosModules = {
      common = {pkgs, ...}: {
        nixpkgs = {
          config.allowUnfree = true;
          overlays = [
            inputs.nur.overlay
            inputs.emacs-overlay.overlay
            inputs.berberman.overlays.default
            (
              final: prev: {
                deploy-rs = {
                  inherit (prev) deploy-rs;
                  inherit ((inputs.deploy-rs.overlay final prev).deploy-rs) lib;
                };
              }
            )
            (final: prev: import ../pkgs final prev)
          ];
        };
        # Enable flakes
        nix = {
          package = pkgs.lix;
          settings = {
            experimental-features = ["nix-command" "flakes" "repl-flake"];
            trusted-users = ["@wheel"];
            allowed-users = ["@wheel"];
          };
          optimise.automatic = true;
          gc = {
            automatic = true;
            dates = "weekly";
            options = "--delete-older-than 30d";
          };
          buildMachines = [
            {
              hostName = "192.168.0.128";
              sshUser = "root";
              system = "aarch64-linux";
              maxJobs = 1;
              speedFactor = 10;
              supportedFeatures = ["benchmark" "big-parallel" "kvm" "nixos-test"];
              mandatoryFeatures = [];
            }
          ];
          distributedBuilds = true;
          # Automatically run GC whenever there is not enough space left
          # Bytes
          extraOptions = ''
            min-free = ${toString (100 * 1024 * 1024)}
            max-free = ${toString (1024 * 1024 * 1024)}
            builders-use-substitutes = true
          '';
        };
        imports = [
          ../cachix
          ./nixos/globalvars.nix
          ./nixos/warnings.nix
        ];
      };
      # NixOS specific configuration
      linuxModules = {...}: {
        imports = [
          ../hosts/generic.nix
          ./nixos/deploy.nix
          ./nixos/virtualisation
          ./nixos/sysconf
          ./nixos/services
          ./nixos/desktop
          inputs.nixtendo-switch.nixosModules.nixtendo-switch
          inputs.psilocybin.nixosModules.psilocybin
          inputs.nur.nixosModules.nur
          inputs.chaotic.nixosModules.default
          inputs.aagl.nixosModules.default
        ];
      };
    };

    homeModules = {
      # Common home-manager configuration
      common = {...}: {
        imports = [
          ../home/shell
          inputs.chaotic.homeManagerModules.default
          inputs.nix-flatpak.homeManagerModules.nix-flatpak
        ];
      };
      # home-manager config for desktop
      desktop = {...}: {
        imports = [
          ../home/desktop
          ../home/desktop/cosmic
          ../home/files.nix
          ../home/xdg.nix
          inputs.schizofox.homeManagerModule
        ];
      };
    };
  };
}
