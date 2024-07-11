{
  lib,
  config,
  inputs,
  ...
}:
with lib; let
  cfg = config.modules.shell.starship;
in {
  options = {
    modules.shell.starship = {
      enable = mkOption {
        type = types.bool;
        default = true;
      };
    };
  };
  config = mkIf cfg.enable {
    programs.starship = let
      flavour = "mocha"; # One of `latte`, `frappe`, `macchiato`, or `mocha`
    in {
      enable = true;
      enableFishIntegration = true;
      enableNushellIntegration = true;
      settings =
        {
          add_newline = true;
          format = lib.concatStrings ["$all"];

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
        // builtins.fromTOML (
          builtins.readFile "${inputs.catppuccin-starship.outPath}/palettes/${flavour}.toml"
        );
    };
  };
}
