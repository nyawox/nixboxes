{
  pkgs,
  username,
  ...
}: let
  apps = {
    env = "/run/current-system/sw/bin:/run/wrappers/bin:/home/${username}/.nix-profile/bin:/etc/profiles/per-user/${username}/bin:/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin";
    apps = [
      {
        name = "Desktop";
        image-path = "desktop.png";
      }
    ];
  };
in {
  home.file = {
    ".wallpaper.png".source = pkgs.fetchurl {
      url = "https://www.pixelstalk.net/wp-content/uploads/images8/Desktop-Wallpaper-Free-Download.jpg";
      sha256 = "11k6n82l09gnvr885y71pngvwqw48n9vwwa7zx2hgh4r6wmb05gn";
    };
    ".doom.d/splash.png".source =
      pkgs.fetchFromGitHub
      {
        owner = "jeetelongname";
        repo = "doom-banners";
        rev = "38f24e1e5bbd190bb805fcaa400143eb2b426e71";
        sha256 = "DNa6Nqh0OcXP17o0soSkKUYASA+BBufq3uCrXMFSnmY=";
      }
      + "/splashes/emacs/emacs-e-logo.png";
    ".local/share/PrismLauncher/themes/Catppuccin-Mocha".source = let
      zip = pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/catppuccin/prismlauncher/423e359d6c17b0339e8c851bb2953bcf5c7e1e49/themes/Mocha/Catppuccin-Mocha.zip";
        sha256 = "03y76qlsnrjkvd79his5jlaq9rqp2j3x1g101js0sm4iiv4q0l5a";
      };
    in
      pkgs.stdenv.mkDerivation {
        name = "catppuccin-prismlauncher";
        nativeBuildInputs = [pkgs.unzip];
        src = zip;
        sourceRoot = ".";
        unpackCmd = "unzip $src";
        dontConfigure = true;
        dontBuild = true;
        installPhase = ''
          mkdir -p $out
          cp -R Catppuccin-Mocha/* $out/
        '';
      };
  };
  xdg.configFile = {
    "cava/config".source =
      pkgs.fetchFromGitHub
      {
        owner = "catppuccin";
        repo = "cava";
        rev = "ad3301b50786e22e31cbf4316985827d6f05845e";
        sha256 = "hYC6ExtroRy2UoxGNHAzKm9MlTdJSegUWToat4VoN20=";
      }
      + "/mocha.cava";
    "sunshine/sunshine.conf".source = ./sunshine.conf;
    "sunshine/apps.json".text = builtins.toJSON apps;
  };
}
