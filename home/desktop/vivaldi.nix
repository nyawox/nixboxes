{pkgs, ...}: {
  programs.chromium = {
    enable = true;
    package = pkgs.vivaldi;
  };
}
