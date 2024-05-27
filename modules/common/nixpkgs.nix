{ inputs, ... }:
{
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
      })
      (final: prev: import ../../pkgs final prev)
    ];
  };
}
