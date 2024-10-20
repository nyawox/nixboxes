{inputs, ...}: {
  nixpkgs = {
    config.allowUnfree = true;
    overlays = [
      inputs.nur.overlay
      inputs.berberman.overlays.default
      (final: prev: {
        deploy-rs = {
          inherit (prev) deploy-rs;
          inherit ((inputs.deploy-rs.overlay final prev).deploy-rs) lib;
        };
        calibre = inputs.latest.legacyPackages.${prev.system}.calibre.overrideAttrs (_oldAttrs: {
          doInstallCheck = false; # fails on my aarch64 builder
        }); # until 7.20.0 lands unstable
      })
      (final: prev: import ../../pkgs final prev)
    ];
  };
}
