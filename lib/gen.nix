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
      modules =
        [
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
          })
        ]
        ++ (inputs.nixpkgs.lib.optionals secrets [inputs.secrets.nixosModules.secrets]);
    };

  # Function for generating installer configs
  mkImage = {
    hostname ? "nixosinstaller",
    username ? "nixos",
    desktop ? false,
    secrets ? false,
    platform ? "x86_64-linux",
    format ? "install-iso",
  }:
    inputs.nixos-generators.nixosGenerate {
      system = platform;
      specialArgs = {
        inherit self inputs hostname username platform stateVersion;
      };
      modules =
        [
          self.nixosModules.common
          self.nixosModules.linuxModules
          ../hosts/installer.nix
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
                  ]
                  ++ (inputs.nixpkgs.lib.optionals desktop [self.homeModules.desktop]);
                home.stateVersion = "${stateVersion}";
              };
            };
          })
        ]
        ++ (inputs.nixpkgs.lib.optionals secrets [inputs.secrets.nixosModules.secrets]);
      inherit format;
    };
}
