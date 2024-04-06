{pkgs, ...}: {
  programs.gitui = {
    enable = true;
    theme = builtins.readFile (
      pkgs.fetchFromGitHub {
        owner = "catppuccin";
        repo = "gitui";
        rev = "39978362b2c88b636cacd55b65d2f05c45a47eb9";
        hash = "sha256-kWaHQ1+uoasT8zXxOxkur+QgZu1wLsOOrP/TL+6cfII=";
      }
      + /theme/mocha.ron
    );
  };
}
