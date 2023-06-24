{ inputs, ... }:
{
  nixpkgs = {
    config = {
      allowUnfree = true;
      nvidia.acceptLicense = true;
    };
    overlays = [
      inputs.nur.overlay
      inputs.berberman.overlays.default
      (final: prev: {
        deploy-rs = {
          inherit (prev) deploy-rs;
          inherit ((inputs.deploy-rs.overlay final prev).deploy-rs) lib;
        };
        _7zz = prev._7zz.override { useUasm = true; }; # https://github.com/NixOS/nixpkgs/issues/353119
      })
      (final: prev: import ../../pkgs final prev)
    ];
  };
}
