{
  lib,
  pkgs,
  ...
}: {
  programs.starship = let
    flavour = "mocha"; # One of `latte`, `frappe`, `macchiato`, or `mocha`
  in {
    enable = true;
    enableFishIntegration = true;
    settings =
      {
        add_newline = true;
        format = lib.concatStrings [
          "$all"
        ];

        directory.style = "bold lavender";
        character = {
          success_symbol = "[󰘧](mauve)";
          error_symbol = "[X](red)";
          vimcmd_symbol = "[](green)";
        };

        git_status = {
          style = "maroon";
          ahead = "⇡ ";
          behind = "⇣ ";
          diverged = "⇕ ";
        };

        palette = "catppuccin_${flavour}";
      }
      // builtins.fromTOML (builtins.readFile (pkgs.fetchFromGitHub
        {
          owner = "catppuccin";
          repo = "starship";
          rev = "3e3e54410c3189053f4da7a7043261361a1ed1bc";
          sha256 = "soEBVlq3ULeiZFAdQYMRFuswIIhI9bclIU8WXjxd7oY=";
        }
        + /palettes/${flavour}.toml));
  };
}
