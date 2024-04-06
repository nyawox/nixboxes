{
  self,
  inputs,
  stateVersion,
  ...
}: {
  # Function for generating host configs
  mkLinux = {
    hostname,
    username ? "nyaa",
    desktop ? true,
    secrets ? false,
    deploy ? true,
    platform ? "x86_64-linux",
  }:
    inputs.nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit self inputs hostname username deploy platform stateVersion;
      };
      modules = [
        self.nixosModules.common
        self.nixosModules.linuxModules
        ../hosts/${hostname}
        inputs.home-manager.nixosModules.home-manager
        ({specialArgs, ...}: {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            extraSpecialArgs = specialArgs;
            users."${username}" = {
              imports =
                [
                  self.homeModules.common
                  ../home/hosts/${hostname}
                  ../home/sshconfig.nix
                ]
                ++ (inputs.nixpkgs.lib.optionals desktop [self.homeModules.desktop]);
              home.stateVersion = "${stateVersion}";
            };
          };
          secrets = inputs.nixpkgs.lib.mkIf secrets {
            enable = true;
            enablePassword = true;
          };
        })
      ];
    };
}
