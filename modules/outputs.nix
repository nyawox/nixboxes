{self, ...} @ inputs:
inputs.flake-parts.lib.mkFlake {inherit inputs;} {
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

  flake = let
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
  in {
    nixosConfigurations = with myLib; {
      lolcathost = mkLinux {
        hostname = "lolcathost";
        secrets = true;
      };
      nagisa = mkLinux {
        hostname = "nagisa";
        secrets = true;
      };
      nixpro64 = mkLinux {
        hostname = "nixpro64";
        platform = "aarch64-linux";
        desktop = false;
        secrets = true;
      };
      vultr = mkLinux {
        hostname = "vultr";
        desktop = false;
        secrets = true;
        deploy = false;
      };
      localghost = mkLinux {
        hostname = "localghost";
        desktop = false;
        secrets = true;
      };
      ghostcity = mkLinux {
        hostname = "ghostcity";
        desktop = false;
        secrets = true;
        deploy = false;
      };
      iso = mkISO {platform = "x86_64-linux";};
      isoarm = mkISO {platform = "aarch64-linux";};
    };
  };
}
