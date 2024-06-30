{inputs, ...}: {
  flake = {
    nixosModules = {
      common = {...}: {
        imports = [
          ./common/nixpkgs.nix
          ./common/nix.nix
          ./common/globalvars.nix
          ./common/warnings.nix
          ../cachix
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
          ../home/desktop/niri
          ../home/files.nix
          ../home/xdg.nix
          inputs.schizofox.homeManagerModule
        ];
      };
    };
  };
}
