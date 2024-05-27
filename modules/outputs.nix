{ self, ... }@inputs:
inputs.flake-parts.lib.mkFlake { inherit inputs; } {
  systems = [
    "x86_64-linux"
    "x86_64-darwin"
    "aarch64-linux"
  ];
  imports = [
    inputs.devshell.flakeModule
    inputs.treefmt-nix.flakeModule
    ./deploy.nix
    ./modules.nix
    ./per-system.nix
  ];

  flake =
    let
      inherit (self) outputs;
      # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
      stateVersion = "23.11";
      myLib = import ../lib {
        inherit
          self
          inputs
          outputs
          stateVersion
          ;
      };
    in
    {
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
        #     ./nixos/sysconf/zram.nix
        #   ];
        # };
      };
    };
}
