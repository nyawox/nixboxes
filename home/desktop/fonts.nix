{pkgs, ...}: {
  fonts.fontconfig.enable = true;
  home.packages = with pkgs; [
    corefonts
    spleen
    apple-emoji
    liberation_ttf
    wqy_zenhei
    font-awesome
    (nerdfonts.override {fonts = ["NerdFontsSymbolsOnly"];})
  ];
}
