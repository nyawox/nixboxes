{ pkgs, ... }:
{
  nix = {
    package = pkgs.lix;
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
        "repl-flake"
      ];
      trusted-users = [ "@wheel" ];
      allowed-users = [ "@wheel" ];
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
        supportedFeatures = [
          "benchmark"
          "big-parallel"
          "kvm"
          "nixos-test"
        ];
        mandatoryFeatures = [ ];
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
}
