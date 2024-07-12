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
        inherit
          self
          inputs
          hostname
          username
          deploy
          platform
          stateVersion
          ;
      };
      modules = [
        self.nixosModules.common
        self.nixosModules.linuxModules
        ../hosts/${hostname}
        inputs.home-manager.nixosModules.home-manager
        (
          {specialArgs, ...}: {
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
          }
        )
      ];
    };
  mkISO = {platform}: let
    username = "nixos";
    hostname = "nixos-installer";
    deploy = false;
  in
    inputs.nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit self inputs hostname username deploy platform stateVersion;
      };
      modules = [
        "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
        self.nixosModules.common
        ({pkgs, ...}: {
          nixpkgs.hostPlatform = platform;
          users.users.nixos.openssh.authorizedKeys.keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ+HhlLh3dtTBvWN6WO8gHma2BoGupqhjVuy2raQ+JS2 nyawox.git@gmail.com"
          ];
          environment.systemPackages = with pkgs; [
            rsync
          ];
        })
        ../modules/nixos/sysconf/zram.nix
      ];
    };
}
