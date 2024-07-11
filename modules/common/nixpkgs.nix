{inputs, ...}: {
  nixpkgs = {
    config.allowUnfree = true;
    overlays = [
      inputs.nur.overlay
      inputs.emacs-overlay.overlay
      inputs.berberman.overlays.default
      (final: prev: {
        deploy-rs = {
          inherit (prev) deploy-rs;
          inherit ((inputs.deploy-rs.overlay final prev).deploy-rs) lib;
        };
        # until miniupnpc gets reverted to a working version in nixos-unstable
        inherit (inputs.latest.legacyPackages.${prev.system}) miniupnpc;
      })
      (final: prev: import ../../pkgs final prev)
    ];
  };
}
