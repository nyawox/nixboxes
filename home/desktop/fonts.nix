{pkgs, ...}: {
  fonts.fontconfig.enable = true;
  home.packages = with pkgs; [
    corefonts
    spleen
    ibm-plex
    apple-emoji
    liberation_ttf
    wqy_zenhei
    font-awesome
    (nerdfonts.override {fonts = ["IBMPlexMono" "NerdFontsSymbolsOnly"];})
  ];
}
