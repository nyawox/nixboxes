final: prev: {
  # keep sources this first
  sources = prev.callPackage (import ./_sources/generated.nix) {};
  # then, call packages with `final.callPackage`
  #examplepkg = final.callPackage (import ./examplepkg.nix) { };
  fcitx5-catppuccin = final.callPackage (import ./fcitx5-catppuccin.nix) {};
}
