final: prev: {
  # keep sources this first
  sources = prev.callPackage (import ./_sources/generated.nix) {};
  # then, call packages with `final.callPackage`
  #examplepkg = final.callPackage (import ./examplepkg.nix) { };
  catppuccin-fcitx5 = final.callPackage (import ./catppuccin-fcitx5.nix) {};
  lsp-ai = final.callPackage (import ./lsp-ai.nix) {};
}
