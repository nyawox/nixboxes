{
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.modules.shell.git;
in {
  options = {
    modules.shell.git = {
      enable = mkOption {
        type = types.bool;
        default = true;
      };
    };
  };
  config = mkIf cfg.enable {
    programs.git = {
      enable = true;

      extraConfig.pull.rebase = false;

      userEmail = "nyawox.git@gmail.com";
      userName = "nyawox";
    };
  };
}
