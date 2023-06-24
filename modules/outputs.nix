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
      # https://wiki.nixos.org/wiki/FAQ/When_do_I_update_stateVersion
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
      nixosConfigurations = with myLib; {
        lolcathost = mkNixos {
          hostname = "lolcathost";
          secrets = true;
        };
        localtoast = mkNixos {
          hostname = "localtoast";
          secrets = true;
        };
        localpost = mkNixos {
          hostname = "localpost";
          platform = "aarch64-linux";
          desktop = false;
          secrets = true;
        };
        localghost = mkNixos {
          hostname = "localghost";
          desktop = false;
          secrets = true;
        };
        localhostage = mkNixos {
          hostname = "localhostage";
          desktop = false;
          secrets = true;
          deploy = false;
        };
        # iso = mkISO {platform = "x86_64-linux";};
        # isoarm = mkISO {platform = "aarch64-linux";};
      };
    };
}
