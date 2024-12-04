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
        # the release version is too old
        firejail = prev.firejail.overrideAttrs (_old: {
          src = prev.fetchFromGitHub {
            owner = "netblue30";
            repo = "firejail";
            rev = "4e8253a6951cd9fc751ff28bcaacdc2d8c7edfc5";
            hash = "sha256-dDTvpHQRQF62j8SldarxnQ8f/Nd892gXnoQPGsXxfg4=";
          };
        });
      })
      (final: prev: import ../../pkgs final prev)
    ];
  };
}
