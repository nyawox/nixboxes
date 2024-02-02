{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    latest.url = "github:nixos/nixpkgs";
    # Make sure to follow nixpkgs to unclutter lock file
    nix-darwin = {
      url = "github:lnl7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      # url = "github:nix-community/home-manager";
      # https://github.com/nix-community/home-manager/issues/4912
      url = "github:xopclabs/home-manager/floorp-browser";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    emacs-overlay = {
      url = "github:nix-community/emacs-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    helix = {
      url = "github:helix-editor/helix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs-wayland = {
      url = "github:nix-community/nixpkgs-wayland";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sddm-sugar-catppuccin = {
      url = "github:TiagoDamascena/sddm-sugar-catppuccin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    berberman = {
      url = "github:berberman/flakes";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nvfetcher.follows = "nvfetcher";
    };
    nvfetcher = {
      url = "github:berberman/nvfetcher";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    programsdb = {
      url = "github:wamserma/flake-programs-sqlite";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    nix-minecraft = {
      url = "github:Infinidoge/nix-minecraft";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    srvos = {
      url = "github:nix-community/srvos";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-switch-boot = {
      url = "github:nyawox/nix-switch-boot";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    secrets = {
      url = "git+ssh://git@codeberg.org/nyawox/secrets.git?ref=main";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
    };
    nixpkgs-f2k = {
      url = "github:moni-dz/nixpkgs-f2k";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mozilla-addons-to-nix = {
      url = "sourcehut:~rycee/mozilla-addons-to-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hardened-firefox = {
      url = "github:arkenfox/user.js";
      flake = false;
    };
    impermanence.url = "github:nix-community/impermanence";
    nur.url = "github:nix-community/nur";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs @ {self, ...}:
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
        };
        installer-x64 = myLib.mkImage {};
        installer-arm = myLib.mkImage {platform = "aarch64-linux";};

        nixosModules = {
          common = {...}: {
            nixpkgs = {
              config = {
                allowUnfree = true;
                permittedInsecurePackages = [
                  # https://github.com/NixOS/nixpkgs/issues/269713
                  "openssl-1.1.1w"
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
              # Automatically run GC whenever there is not enough space left
              # Bytes
              extraOptions = ''
                min-free = ${toString (1 * 1024 * 1024 * 1024)}
                max-free = ${toString (2 * 1024 * 1024 * 1024)}
              '';
            };
            imports = [
              ./cachix
              ./modules/nixos/globalvars.nix
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
              ./modules/nixos/services/monitoring
              ./modules/nixos/desktop
              inputs.impermanence.nixosModules.impermanence
              inputs.lanzaboote.nixosModules.lanzaboote
              inputs.disko.nixosModules.disko
              inputs.srvos.nixosModules.roles-prometheus
              inputs.srvos.nixosModules.mixins-telegraf
              inputs.nix-switch-boot.nixosModules.nix-switch-boot
              inputs.stylix.nixosModules.stylix
              inputs.nix-minecraft.nixosModules.minecraft-servers
              inputs.nur.nixosModules.nur
            ];
          };
        };

        homeModules = {
          # Common home-manager configuration
          common = {...}: {imports = [./home/shell];};
          # home-manager config for desktop
          desktop = {...}: {
            imports = [
              ./home/desktop
              ./home/desktop/hyprland
              ./home/desktop/waybar
              ./home/files.nix
              ./home/xdg.nix
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
            # inputs.mozilla-addons-to-nix.packages.${pkgs.system}.default
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
              name = "installx64";
              help = "Build NixOS x86-64 installer iso";
              command = "nix build .#installer-x64";
              category = "images";
            }
            {
              name = "installarm";
              help = "Build NixOS AArch64 installer iso";
              command = "nix build .#installer-arm";
              category = "images";
            }
          ];
        };
      };
    };
}
