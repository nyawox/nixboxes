{
  pkgs,
  username,
  inputs,
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
    ".wallpaper.jpg".source = pkgs.fetchurl {
      url = "https://i.pinimg.com/originals/24/ca/db/24cadbfc4de7599a86ef5e8bc238853e.jpg";
      sha256 = "1fraqngiw0l164i1ar7i3bzq0bz7zdcvydqgxrr0rqqq3y4rq6sv";
    };
    ".doom.d/splash.png".source = inputs.doom-banners.outPath + "/splashes/emacs/emacs-e-logo.png";
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
    "cava/config".source = inputs.catppuccin-cava.outPath + "/mocha.cava";
    "sunshine/sunshine.conf".source = ./sunshine.conf;
    "sunshine/apps.json".text = builtins.toJSON apps;
    "nwg-drawer/drawer.css".text = ''
      window {
          background-color: rgba (17, 17, 27, 0.98);
          color: #cdd6f4
      }
    '';
    "Element/config.json".source = inputs.catppuccin-element.outPath + "/config.json";
  };
}
