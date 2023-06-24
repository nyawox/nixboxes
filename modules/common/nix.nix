{
  pkgs,
  config,
  ...
}:
{
  config = {
    nix = {
      package = pkgs.lix;
      settings = {
        experimental-features = [
          "nix-command"
          "flakes"
          "repl-flake"
        ];
        trusted-users = [ "@wheel" ];
        allowed-users = [ "@wheel" ];
        extra-platforms = config.boot.binfmt.emulatedSystems;
      };
      optimise.automatic = true;
      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 30d";
      };
      # Automatically run GC whenever there is not enough space left
      # Bytes
      extraOptions =
        # conf
        ''
          min-free = ${toString (100 * 1024 * 1024)}
          max-free = ${toString (1024 * 1024 * 1024)}
          builders-use-substitutes = true
        '';
    };
  };
}
