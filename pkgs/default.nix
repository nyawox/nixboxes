final: _prev: {
  catppuccin-fcitx5 = final.callPackage (import ./catppuccin-fcitx5.nix) { };
  lsp-ai = final.callPackage (import ./lsp-ai.nix) { };
  fast-font = final.callPackage (import ./fast-font.nix) { };
}
