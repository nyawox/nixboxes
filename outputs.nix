{self, ...} @ inputs:
inputs.flake-parts.lib.mkFlake {inherit inputs;} {
  systems = ["x86_64-linux" "x86_64-darwin" "aarch64-linux"];
  imports = [inputs.devshell.flakeModule inputs.treefmt-nix.flakeModule ./modules/deploy.nix];

  flake = let
    inherit (self) outputs;
    # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    stateVersion = "23.11";
    myLib = import ./lib {inherit self inputs outputs stateVersion;};
  in {
    nixosConfigurations = {
      lolcathost = myLib.mkLinux {
        hostname = "lolcathost";
        secrets = true;
      };
      nagisa = myLib.mkLinux {
        hostname = "nagisa";
        secrets = true;
      };
      nixpro64 = myLib.mkLinux {
        hostname = "nixpro64";
        platform = "aarch64-linux";
        desktop = false;
        secrets = true;
      };
      vultr = myLib.mkLinux {
        hostname = "vultr";
        desktop = false;
        secrets = true;
      };
      tomoyo = myLib.mkLinux {
        hostname = "tomoyo";
        desktop = false;
        secrets = true;
      };
      ghostcity = myLib.mkLinux {
        hostname = "ghostcity";
        desktop = false;
        secrets = true;
        deploy = false;
      };
      #I'm tired of this causing issue when deploying
      # Just uncomment when using it
      # iso = inputs.nixpkgs.lib.nixosSystem {
      #   modules = [
      #     "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
      #     self.nixosModules.common
      #     ({pkgs, ...}: {
      #       # nixpkgs.hostPlatform = "x86_64-linux";
      #       nixpkgs.hostPlatform = "aarch64-linux";
      #       users.users.nixos.openssh.authorizedKeys.keys = [
      #         "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ+HhlLh3dtTBvWN6WO8gHma2BoGupqhjVuy2raQ+JS2 nyawox.git@gmail.com"
      #       ];
      #       environment.systemPackages = with pkgs; [
      #         rsync
      #       ];
      #     })
      #     ./modules/nixos/sysconf/zram.nix
      #   ];
      # };
    };

    nixosModules = {
      common = {pkgs, ...}: {
        nixpkgs = {
          config = {
            allowUnfree = true;
            permittedInsecurePackages = [
              # https://github.com/NixOS/nixpkgs/issues/269713
              # "openssl-1.1.1w"
            ];
          };
          overlays = [
            inputs.nur.overlay
            inputs.emacs-overlay.overlay
            inputs.berberman.overlays.default
            inputs.nix-minecraft.overlay
            (
              final: prev: {
                deploy-rs = {
                  inherit (prev) deploy-rs;
                  inherit ((inputs.deploy-rs.overlay final prev).deploy-rs) lib;
                };
              }
            )
            (final: prev: import ./pkgs final prev)
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
          ./cachix
          ./modules/nixos/globalvars.nix
          ./modules/nixos/warnings.nix
          inputs.sops-nix.nixosModules.sops
        ];
      };
      # NixOS specific configuration
      linuxModules = {...}: {
        imports = [
          ./hosts/generic.nix
          ./modules/nixos/deploy.nix
          ./modules/nixos/virtualisation
          ./modules/nixos/sysconf
          ./modules/nixos/services
          ./modules/nixos/desktop
          inputs.impermanence.nixosModules.impermanence
          inputs.lanzaboote.nixosModules.lanzaboote
          inputs.disko.nixosModules.disko
          inputs.nixtendo-switch.nixosModules.nixtendo-switch
          inputs.psilocybin.nixosModules.psilocybin
          inputs.nixos-cosmic.nixosModules.default
          inputs.stylix.nixosModules.stylix
          inputs.nix-minecraft.nixosModules.minecraft-servers
          inputs.nur.nixosModules.nur
          inputs.chaotic.nixosModules.default
          inputs.nix-flatpak.nixosModules.nix-flatpak
          inputs.aagl.nixosModules.default
          inputs.arion.nixosModules.arion
        ];
      };
    };

    homeModules = {
      # Common home-manager configuration
      common = {...}: {
        imports = [
          ./home/shell
          inputs.chaotic.homeManagerModules.default
          inputs.nix-flatpak.homeManagerModules.nix-flatpak
        ];
      };
      # home-manager config for desktop
      desktop = {...}: {
        imports = [
          ./home/desktop
          ./home/desktop/cosmic
          ./home/files.nix
          ./home/xdg.nix
          inputs.schizofox.homeManagerModule
        ];
      };
    };
  };
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
        (final: prev: import ./pkgs final prev)
      ];
    };
    treefmt = {
      programs = {
        alejandra.enable = true;
        deadnix.enable = true;
        statix.enable = true;
        prettier.enable = true;
        beautysh.enable = true;
        shellcheck.enable = true;
        yamlfmt.enable = true;
      };
      settings.formatter = {
        beautysh.includes = ["remoteinstall" "localinstall"];
        shellcheck.includes = ["remoteinstall" "localinstall"];
      };
      flakeFormatter = true;
      projectRootFile = "flake.nix";
    };
    # Not to be confused with capital S "devShells"
    devshells.default = {
      packages = with pkgs; [
        config.treefmt.build.wrapper
        deploy-rs
        fish
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
      ];
    };
  };
}